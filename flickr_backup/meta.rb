require 'rubygems'
require 'flickraw'
require 'dbi'

# apikey, dsn, user

FlickRaw.api_key = ARGV[0]
dsn = ARGV[1]
user = ARGV[2]

$dbh = DBI.connect(dsn, '', '')
$dbh['AutoCommit'] = false

info = flickr.people.getInfo( :user_id => user )

base = 0
page = 1
pagesize = 500

puts "fetching #{info.photos.count} photos"

# CREATE TABLE exif (id char(12), tag varchar(1024), value varchar(1024), raw varchar(1024), myclean varchar(1024), primary key(id, tag));
# CREATE TABLE photos (id char(12) primary key, secret char(12), title varchar(1024) , taken timestamp, last_update timestamp, ispublic int, isfriend int, isfamily int, upload timestamp);

sth = $dbh.prepare("insert into photos values (?,?,?,?,NULL,?,?,?,?)")
inserttag = $dbh.prepare("insert into exif values (?,?,?,?,?)")

#<FlickRaw::Response:0xb714e800 @isfriend=0, @isfamily=0, @farm=3, @title="Three A's", @secret="1860920ee1", @owner="12708857@N00", @server="2497", @datetaken="2009-10-21 13:15:28", @datetakengranularity="0", @ispublic=1, @lastupdate="1256135177", @id="4031474351">

# cache which photo ids already have EXIF to reduce API calls
phoots = {}
exif_seen = $dbh.select_all('select distinct id from exif')
exif_seen.each { |i|
    phoots[i[0]] = 1
}

limit = info.photos.count.to_i

while base < limit do
    list = flickr.people.getPublicPhotos(
	    :user_id => user,
	    :per_page => pagesize,
	    :page => page,
        :extras => 'date_taken,last_update,date_upload'
    )  
    $dbh.transaction do
	    list.each_with_index do |photo,j|
            next unless phoots[photo.id].nil?

            puts "inserting photo #{photo.id}, #{base+j}"
	        sth.execute(
                photo.id, photo.secret, photo.title, photo.datetaken,
                photo.ispublic, photo.isfriend, photo.isfamily,
                photo.dateupload
            )
# #<FlickRaw::Response:0xb7129654 @label="File Size", @tagspace="File", @raw="316 kB", @tag="FileSize", @tagspaceid=0>
# #<FlickRaw::Response:0xb7129424 @label="File Type", @tagspace="File", @raw="JPEG", @tag="FileType", @tagspaceid=0>,
            exiftags = flickr.photos.getExif(:photo_id => photo.id)
            cached = Hash.new { |h,k| h[k]=Array.new }
            exiftags.exif.each do |tag|
                clean = tag.respond_to?('clean') ? tag.clean : nil
# puts "id=#{photo.id} tag=#{tag.label} raw=#{tag.raw} clean=#{clean}"
                cached[tag.label].push [tag.raw, clean]
            end
            if cached.keys.nil? then
                cached['NoExif'] = ['NoExif']
            end
            begin
	            cached.keys.each do |t|
	                raw = cached[t].map{|i|i[0]}.compact.uniq.join(';;')
	                clean = cached[t].map{|i|i[1]}.compact.uniq.join(';;')
	                nc = clean
	                if t == 'Aperture' then
	                    v = clean.gsub('f/','').to_f
	                    nc = sprintf((v > 9 ? 'f/%d' : 'f/%.1f'), v)
	                end
                    inserttag.execute(photo.id, t, clean, raw, nc)
	            end
	            sleep 1
            rescue SQLite3::SQLException
                next
            end
	    end
    end
    base = base + pagesize
    page = page + 1
    sleep 30
end
