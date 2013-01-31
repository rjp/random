require 'rubygems'
require 'sinatra'
require 'flickraw'
require 'yaml'
require 'haml'
require 'open-uri'
require 'nokogiri'
require 'dbi'
require 'digest'

QUOTE_URL = 'http://www.quotationspage.com/random.php3'

set :port, 4569

config = YAML.load_file("/home/rjp/.flickr")
FlickRaw.api_key = config['api_key']
FlickRaw.shared_secret = config['api_secret']

before do
    @dbh = DBI.connect('DBI:SQLite3:/home/rjp/.cdmeme.db', '', '')
end

get '/' do
    @title = 'CDMeme parts'
    @cdmeme = get_cdmeme_parts()
    parts = [
        @cdmeme[:flickr][:id], @cdmeme[:wiki][:title],
        @cdmeme[:wiki][:link], @cdmeme[:quote]
    ]
    hash = Digest::SHA1.hexdigest(parts.join('.x!|!x.'))[0..11]
    @dbh.do(
        "insert into cdmeme_base
         (hash, flickr_id, wiki_title, wiki_link, quote_words, quote_full, quote_link)
         values (?,?,?,?,?,?,?)",
        hash,
        @cdmeme[:flickr][:id], @cdmeme[:wiki][:title],
        @cdmeme[:wiki][:link], @cdmeme[:quote],
        @cdmeme[:quote_full], @cdmeme[:quote_link]
    )
    @cdmeme[:hash] = hash
    haml :index
end

get %r{/h/([0-9a-fA-F]+)} do |hash|
    cdmeme = @dbh.select_one(
	        "select flickr_id, wiki_title, wiki_link, quote_words
            from cdmeme_base where hash=?",
	        hash
    )
    @title = "CDMeme ##{hash}"
    $stderr.puts cdmeme.inspect
    @cdmeme = {
        :flickr => get_flickr_info(cdmeme[0]),
        :wiki => { :title => cdmeme[1], :link => cdmeme[2] },
        :quote => cdmeme[3]
    }
    haml :index
end

def get_flickr_photo
	allowed = {}
	[1,2,4,5,7].each {|l| allowed[l] = 1}
	
	found = []
	today = Time.now
	1.upto(7) { |ago|
	    date = (today - 86400*ago).strftime('%Y-%m-%d')
        begin
            $stderr.puts "interesting on #{date}"
		    f = flickr.interestingness.getList :extras => 'license', :date => date
		    found.push f.find_all {|x| 1 or allowed[x.license.to_i]}
        rescue => e
            ignore_the_exception = 1
            $stderr.puts e
        end
	}
	return found.flatten.sort_by {rand(Time.now.to_i)} [2] # third
end

def get_flickr_info(id)
	info = flickr.photos.getInfo(:photo_id => id)
    page_url = info.urls.find {|x| x.type == 'photopage' }._content
    user = info.owner.username
    title = info.title

	sizes = flickr.photos.getSizes(:photo_id => id)
    $stderr.puts sizes.inspect

    thumbnail = sizes.find {|x| x.label == 'Medium'}.source

	return {
        :page => page_url, :thumb => thumbnail,
        :title => title, :user => user,
        :id => id
    }
end

def get_flickr
    photo = get_flickr_photo()
    return get_flickr_info(photo.id)
end

def get_wikipedia
    a = nil
    1.upto(5) do
        a = Nokogiri(open("http://en.wikipedia.org/wiki/Special:Random", "User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.0.1) Gecko/2008070206 Firefox/3.0.1"))
        # Don't use anyone in "Living People" or "[year] deaths"
        if a.at("a[@href*='Living_people']").nil? then
            break
        end
        if a.at("a[@href*='deaths']").nil? then
            break
        end
        sleep 1
    end
    if a.nil? then
        return { :link => '/', :title => 'WikiFail' }
    end
    link = (a.at('div.printfooter')/:a)[0]['href']
    title = (a/:title).inner_html.gsub(/ - .*$/,'')
    return { :link => link, :title => title }
end

def get_quote
    a = Nokogiri(open(QUOTE_URL))
    quote = a.css('dt.quote')[-1]
    link = quote.at('a')['href']
    text = quote.inner_text.gsub(/[^A-Za-z0-9]+$/,'')
    quote_words = text.split(' ')[-5..-1].join(' ')

    resolved_link = URI(QUOTE_URL)
    resolved_link.path = link

    return quote_words, text, resolved_link
end

def get_cdmeme_parts
    qw, q, l = get_quote()
    return {
        :flickr => get_flickr(),
        :wiki => get_wikipedia(),
        :quote => qw,
        :quote_full => q,
        :quote_link => l
    }
end
