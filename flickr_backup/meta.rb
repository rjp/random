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

# CREATE TABLE queue (id char(12) primary key, upload timestamp, got_info timestamp, got_exif timestamp);

last_photo = $dbh.select_one('select max(upload) from queue')
last_upload = last_photo[0].nil? ? 0 : Time.parse(last_photo[0]).to_i

if last_upload > 0 then
    puts "fetching since #{Time.at(last_upload)}"
end

# ignore primary key conflicts, we're guaranteed to get them
queue = $dbh.prepare("insert or ignore into queue values (?,?,NULL,NULL)")

loop do
    list = flickr.photos.search(
	    :user_id => user,
	    :per_page => pagesize,
	    :page => page,
        :extras => 'date_upload',
        :sort => 'date-posted-asc',
        :min_upload_date => last_upload
    )

    if list.size == 0 then
        break
    end

    # queue all the photos we've just got from flickr
    $dbh.transaction do 
        list.each do |photo|
        # <photo id="4862693" owner="12708857@N00" secret="982c7066df" 
        #  server="3" farm="1" title="Early sunrise" ispublic="1" 
        #  isfriend="0" isfamily="0" dateupload="1108498665"/>
            id = photo.id
            upload = Time.at(photo.dateupload.to_i)
            queue.execute(id, upload)
        end
    end

    page = page + 1
end
