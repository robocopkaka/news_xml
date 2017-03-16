require 'zip'
require 'nokogiri'
require 'redis'
redis = Redis.new
Zip::File.open("download.zip") do |file| 
	  file.each do |content|
	    data = file.read(content) #reads the content of the file
	    doc = Nokogiri::XML(data).css("post") #Nokogiri parses the contents of data
	    redis.lrem('NEWS_XML',0, doc)
		redis.rpush 'NEWS_XML', doc # pushes the content of the file to the NEWS_XML list if it wasn't already there
	    #puts @doc.css("post_url")
	    # Do whatever you want with the contents
	  end
end
puts redis.lrange('NEWS_XML',0,2)
puts redis.llen 'NEWS_XML'