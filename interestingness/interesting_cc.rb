require 'rubygems'
require 'flickraw'
require 'yaml'

allowed = {}
[1,2,4,5,7].each {|l| allowed[l] = 1}

config = YAML.load_file("#{ENV['HOME']}/.flickr")
FlickRaw.api_key = config['api_key']

found = []
today = Time.now
1.upto(7) { |ago|
    date = (today - 86400*ago).strftime('%Y-%m-%d')
    begin
    f = flickr.interestingness.getList :extras => 'license', :date => date
    found.push f.find_all {|x| allowed[x.license.to_i]}
    rescue => e
    end
}
use = found.flatten.sort_by {rand(Time.now)} [2] # third
info = flickr.photos.getInfo(:photo_id => use.id)
puts info.urls.find {|x| x.type == 'photopage' }._content
