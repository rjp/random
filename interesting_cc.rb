require 'flickr'
require 'yaml'

allowed = {}
[1,2,4,5,7].each {|l| allowed[l] = 1}

config = YAML.load_file("#{ENV['HOME']}/.flickr")
flickr = Flickr.new(api_key = config['api_key'])

found = []
today = Time.now
1.upto(7) { |ago|
    date = (today - 86400*ago).strftime('%Y-%m-%d')
    f = flickr.interestingness_getList('extras'=>'license', 'date'=>date);
    found.push f['photos']['photo'].find_all {|x| allowed[x['license'].to_i]}
}
p found.size
