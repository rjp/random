require 'flickraw'
require 'yaml'

allowed = {}
[1,2,4,5,7].each {|l| allowed[l] = 1}

config = YAML.load_file("#{ENV['HOME']}/.flickr")
flickr = Flickr.new(api_key = config['api_key'])
$client = flickr

found = []
today = Time.now
1.upto(7) { |ago|
    date = (today - 86400*ago).strftime('%Y-%m-%d')
    f = flickr.interestingness.getList :extras => 'license', :date => date
    found.push f.find_all {|x| allowed[x.license.to_i]}
}
use = found.flatten.sort_by {rand(Time.now)} [2] # third
p use
photo = flickr.photos.getSizes(:photo_id => use.id)
original = photo.find { |s| s.label == 'Original' }
puts original
