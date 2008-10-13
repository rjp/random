require 'flickr'
require 'yaml'

allowed = {}
[1,2,4,5,7].each {|l| allowed[l] = 1}

config = YAML.load_file("#{ENV['HOME']}/.flickr")
flickr = Flickr.new(api_key = config['api_key'])

x = flickr.interestingness_getList('extras'=>'license', 'date'=>'2008-10-10');
x['photos']['photo'].find_all {|x| allowed[x['license'].to_i]}.each { |p|
    p p
}
