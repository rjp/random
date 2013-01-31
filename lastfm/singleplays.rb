require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'json'

# ~/.apikeys.js => {"lastfm":{"apikey":"__your_last_fm_apikey__"}}
keys = JSON.load(open(ENV['HOME'] + "/.apikeys.js"))
api_key = keys['lastfm']['apikey']

who = ARGV[0]
if who.nil? then
    puts "! Need a username"
    exit
end

# fake OO to encapsulate the username and api_key into each request
def make_get_xml(who, api_key)
    return lambda {|method, extra|
        begin
            io = open("http://ws.audioscrobbler.com/2.0/?method=#{method}&user=#{who}&api_key=#{api_key}&#{extra}")
            if io.status[0].to_i != 200 then
                puts "? " + io.status[0]
            end
            return Nokogiri::XML(io.read)
        rescue OpenURI::HTTPError => e
            nd = Nokogiri::XML(e.io.read)
            puts "! " + nd.at('//lfm/error').inner_text
            exit
        end

        return nd
    }
end

# create our "object"
gx = make_get_xml(who, api_key)

# find out how many tracks we have in the library
nd = gx.call('library.gettracks', 'limit=1')
counts = nd.at('//tracks')
total = counts.attr('totalPages').to_i

# I am becoming very fond of the single identifying character logging
puts "U #{who}"
puts "T #{total}"

# find out how many plays the user has done
nd = gx.call('user.getInfo', 'limit=1')
plays = nd.at('//user/playcount').inner_text.to_i
puts "P #{plays}"

# random user-settable variables
limit = 1000
maxpages = 10000
minplays = 2

# random non-user-interacting variables
page = 1
mintracks = 0
examined = 0

loop do
    # fetch a page of tracks
    puts "R #{page} #{limit}"
    nd = gx.call('library.gettracks', "limit=#{limit}&page=#{page}")
    pageinfo = nd.at('//tracks')
    totalpages = pageinfo.attr('totalPages').to_i
    nd.search('//track').each do |t|
        tc = t.at('playcount').inner_text.to_i
        if tc < minplays then
            mintracks = mintracks + 1
        end
        examined = examined + 1
    end
    page = page + 1
    # if we're done, break out and print the results
    if page > totalpages then
        break
    end
    # maybe someone always wants to bail out after 100 pages regardless
    if page > maxpages then
        break
    end
end

puts "S #{mintracks} < #{minplays}"
puts "E #{examined}"
