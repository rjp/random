require 'rubygems'
require 'hpricot'
require 'open-uri'

url=ARGV[0]
doc = Hpricot(open(url))
doc.search('//title') { |t|
    puts t.inner_text
}

