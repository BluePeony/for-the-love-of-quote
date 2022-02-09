require 'mysql2'
require 'twitter'
require 'rmagick'
require '/home/anna/ruby/Projekte/twitter_quotes_bot/general/config_general.rb'
include Magick

#---------------------------------Pick a quote----------------------------------
#build a connection to the database 'quotes_db'
db_client = Mysql2::Client.new(:host => @host, :username => @username, :password => @pw, :database => @database)

#select all quotes which are not used yet and count them
not_used_request = "SELECT * FROM #{@db_table} WHERE quote_status = \'not used\'"
not_used_req_result = db_client.query(not_used_request, :as => :array)
not_used_req_count = not_used_req_result.count

if not_used_req_count == 0 #all quotes have been used -> set all quotes back to 'not used', then select all 'not used' quotes again
	update_req = "UPDATE #{@db_table} SET quote_status = 'not used'"
	db_client.query(update_req)
	not_used_req_result = db_client.query("SELECT * FROM #{@db_table}", :as => :array)
	not_used_req_count = not_used_req_result.count
end

not_used_req_array = not_used_req_result.to_a
ind = rand(not_used_req_count)
quote_text = not_used_req_array[ind][1]
quote_author = not_used_req_array[ind][2]

quote_text = "\"" + quote_text.strip + "\""

tweet_to_quote = "\"" + quote_text.strip + "\"" + " " + quote_author

#mark the used quote as 'used' in the database
q_text_for_db = quote_text.gsub(/'/, "''")
update_req = "UPDATE #{@db_table} SET quote_status = 'used' WHERE quote_text = '#{q_text_for_db}'"
db_client.query(update_req)

#close the connection to the database
db_client.close

#--------------------------- Create a picture with the quote
img_width = 1707.0
img_height = 1138.0
row_height = 80 # Achtung, das ist abhänging von der Schriftart und Schriftgröße
qt_pointsize = 85
qa_pointsize = 60
text_font = "#{@path}/Rise_Of_Kingdom.ttf"

 i = rand(2)
 if i == 0
	img = ImageList.new("#{@path}/images/ziel_blau.jpg")
 else
	img = ImageList.new("#{@path}/images/ziel_red.jpg")
 end

img = ImageList.new("#{@path}/images/milky_way.jpg")
qt_length = quote_text.length

def get_all_qt_metrics(pic_width, pic_height, text, qt_pointsize, font)
	test_pic = Image.new(pic_width, pic_height)
	test_draw = Draw.new
	test_draw.annotate(test_pic, 0, 0, 50, 200, text) do
		self.font = font
		self.pointsize = qt_pointsize
		self.fill = '#fffff4'
		self.stroke = 'none'
	end

	return test_draw.get_type_metrics(test_pic, text)
end

def get_all_qa_metrics(pic_width, pic_height, text, qa_pointsize, font)
	test_pic = Image.new(pic_width, pic_height)
	test_draw = Draw.new
	test_draw.annotate(test_pic, 0, 0, 50, 200, text) do
		self.font = font
		self.pointsize = qa_pointsize
		self.fill = '#fffff4'
		self.stroke = 'none'
	end

	return test_draw.get_type_metrics(test_pic, text)
end

def draw_text_on_pic(img, img_draw, qt_x_offset, qt_y_offset, qt_text, qt_pointsize, font)
	img_draw.annotate(img, 0, 0, qt_x_offset, qt_y_offset, qt_text) do 
		self.font = font
		self.pointsize = qt_pointsize
		self.fill = '#fffff4'
		self.stroke = 'none'
	end

end

def draw_author_on_pic(img, img_draw, qa_x_offset, qa_y_offset, qt_author, qa_pointsize, font)
	img_draw.annotate(img, 0, 0, qa_x_offset, qa_y_offset, qt_author) do 
		self.font = font
		self.pointsize = qa_pointsize
		self.fill = '#fffff4'
		self.stroke = 'none'
	end
end

if qt_length <= 41
	#Stelle das Bild dar...

	qt_metrics = get_all_qt_metrics(img_width, img_height, quote_text, qt_pointsize, text_font)
	qt_width = qt_metrics['width']
	qt_height = qt_metrics['height']
	qt_x_offset = (img_width - qt_width)/2
	qt_y_offset = (img_height - qt_height)/2

	qa_metrics = get_all_qa_metrics(img_width, img_height, quote_author, qa_pointsize, text_font)
	qa_width = qa_metrics['width']
	qa_height = qa_metrics['height']
	qa_x_offset = (img_width - qt_x_offset - qa_width)
	qa_y_offset = (qt_y_offset + qt_height + 40)

	img_draw = Draw.new
	draw_text_on_pic(img, img_draw, qt_x_offset, qt_y_offset, quote_text, qt_pointsize, text_font)
	draw_author_on_pic(img, img_draw, qa_x_offset, qa_y_offset, quote_author, qa_pointsize, text_font)

else # qt_length > 41 and quote must be splitted into rows
	qt_array = quote_text.split(/ /)
	rows = Array.new()
	row_text = ""

	qt_array.each do |word|
		row_length = row_text.length
		word_length = word.length
 
		if row_length + word_length <= 41
			if row_length + word_length <= 40
				row_text += word + " "
			else
				row_text += word
			end
		else
			rows << row_text
			row_text = word + " " 
		end
	end
	rows << row_text

	#-------------mehrzeiliges Zitat: Zitat auf das Bild bringen
	row_y_offset_start = (img_height - (row_height*rows.size + 50.0*(rows.size-1))) / 2
	row_x_offset_min = 0
	row_x_offset_array = []
	last_row_y_offset = 0
	img_draw = Draw.new

	rows.each_with_index do |row, index|
		
		row_metrics = get_all_qt_metrics(img_width, img_height, row, qt_pointsize, text_font)
		row_width = row_metrics['width']

		row_x_offset = (img_width - row_width)/2
		row_x_offset_array << row_x_offset

		row_y_offset = row_y_offset_start + (row_height + 50) * index

		draw_text_on_pic(img, img_draw, row_x_offset, row_y_offset, row, qt_pointsize, text_font)
		last_row_y_offset = row_y_offset
	end

	row_x_offset_min = row_x_offset_array.min


	#-------------Zitatenautor aufs Bild bringen
	
	qa_metrics = get_all_qa_metrics(img_width, img_height, quote_author, qa_pointsize, text_font)
	qa_width = qa_metrics['width']
	qa_height = qa_metrics['height']
	qa_x_offset = img_width - row_x_offset_min - qa_width
	qa_y_offset = last_row_y_offset + row_height + 30

	draw_author_on_pic(img, img_draw, qa_x_offset, qa_y_offset, quote_author, qa_pointsize, text_font)

end

img.write("#{@path}/img_to_post_general.jpg")

#--------------------Tweet the picture

#connect to the Twitter account
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = @consumer_key
  config.consumer_secret     = @consumer_secret
  config.access_token        = @access_token
  config.access_token_secret = @access_token_secret
end

# #tweet the quote
#client.update(tweet_to_quote)
#client.update_with_media('#quote', File.new("#{@path}/img_to_post_general.jpg"))


exit
