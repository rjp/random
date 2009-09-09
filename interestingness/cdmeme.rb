require 'rubygems'
require 'sinatra'
require 'flickraw'
require 'yaml'
require 'haml'
require 'open-uri'
require 'hpricot'

set :port, 4569

get '/' do
    @title = 'CDMeme parts'
    @cdmeme = get_cdmeme_parts()
    haml :index
end

def get_flickr
	allowed = {}
	[1,2,4,5,7].each {|l| allowed[l] = 1}
	
	config = YAML.load_file("/home/rjp/.flickr")
	FlickRaw.api_key = config['api_key']
	
	found = []
	today = Time.now
	1.upto(7) { |ago|
	    date = (today - 86400*ago).strftime('%Y-%m-%d')
	    f = flickr.interestingness.getList :extras => 'license', :date => date
	    found.push f.find_all {|x| allowed[x.license.to_i]}
	}
	use = found.flatten.sort_by {rand(Time.now)} [2] # third

	info = flickr.photos.getInfo(:photo_id => use.id)
    page_url = info.urls.find {|x| x.type == 'photopage' }._content
    user = info.owner.username
    title = info.title

	sizes = flickr.photos.getSizes(:photo_id => use.id)
    $stderr.puts sizes.inspect

    thumbnail = sizes.find {|x| x.label == 'Medium'}.source

	return { 
        :page => page_url, :thumb => thumbnail,
        :title => title, :user => user
    }
end

def get_wikipedia
    a = Hpricot(open("http://en.wikipedia.org/wiki/Special:Random"))
    link = (a.at('div.printfooter')/:a)[0]['href']
    title = (a/:title).inner_html.gsub(/ - .*$/,'')
    return { :link => link, :title => title }
end

def get_quote
    a = Hpricot(open("http://www.quotationspage.com/random.php3"))
    return a.search('//dt.quote')[-1].inner_text.gsub(/[^A-Za-z0-9]+$/,'').split(' ')[-5..-1].join(' ')
end

def get_cdmeme_parts
    return {
        :flickr => get_flickr(),
        :wiki => get_wikipedia(),
        :quote => get_quote()
    }
end
