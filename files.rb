require 'open-uri'
require 'nokogiri'
require 'httparty'
require 'zip'
require 'redis'

redis = Redis.new
url = "http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/"
page = open(url)

html = Nokogiri::HTML(page)
arr = []
# Converts the links to each zip file to text and stores them in an array 
links = html.css('td a').map do |link| 
	arr.push(link.text)
end
arr.shift # removes the first element in the array

arr[0,1].each do |link|
	zipfile = Tempfile.new("file") #creates a temporary zip file
	zipfile.binmode # This might not be necessary depending on the zip file
	zipfile.write(HTTParty.get("http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/#{link}").body) #saves the zip to the temporary file
	zipfile.close

	# loops through each file extracted from the temporary zipped file 
	Zip::File.open(zipfile.path) do |file| 
	  file.each do |content|
	    data = file.read(content) #reads the content of the file
	    @doc = Nokogiri::XML(data) #Nokogiri parses the contents of data
	    redis.lrem('NEWS_XML',1, @doc) == 0
		redis.rpush 'NEWS_XML', @doc # pushes the content of the file to the NEWS_XML list if it wasn't already ther
	    #puts @doc.css("post_url")
	    # Do whatever you want with the contents
	  end
	end
end
#puts redis.lrange('NEWS_XML',0,2)
puts redis.llen 'NEWS_XML'
# puts arr.inspect
# download = open("http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/#{link}")
#     IO.copy_stream(download, "C:\Users\Onyekachi\workspace2\nuvi\#{link}")

# download = open("http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/1489257731918.zip")
# IO.copy_stream(download, 'C:\Users\Onyekachi\workspace2\nuvi\download.zip')