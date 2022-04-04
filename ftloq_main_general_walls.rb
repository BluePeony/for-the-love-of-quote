require 'mysql2'
require 'twitter'
require 'rmagick'
require '/home/anna/ruby/Projekte/twitter_quotes_bot/general/img_init_general_walls.rb'
require '/home/anna/ruby/Projekte/twitter_quotes_bot/general/config_general.rb'
#require '/home/fortheloveofquote/projects/twitter_quotes_bot/football/img_init_football_quotes.rb'
#require '/home/fortheloveofquote/projects/twitter_quotes_bot/football/config_football.rb'
include Magick

#---------------------------------Pick a quote----------------------------------
# Builds a connection to the database 'quotes_db'
db_client = Mysql2::Client.new(:host => @host, :username => @username, :password => @pw, :database => @database)

# Selects all quotes which are not used yet and count them
not_used_request = "SELECT * FROM #{@db_table} WHERE quote_status = \'not used\'"
not_used_req_result = db_client.query(not_used_request, :as => :array)
not_used_req_count = not_used_req_result.count

if not_used_req_count == 0 # All quotes have been used -> set all quotes back to 'not used', then select all 'not used' quotes again also remove all images and view pages from the website. 
# Everything will begin from Zero	
	update_req = "UPDATE #{@db_table} SET quote_status = 'not used'"
	db_client.query(update_req)
	not_used_req_result = db_client.query("SELECT * FROM #{@db_table}", :as => :array)
	not_used_req_count = not_used_req_result.count
	system("rm #{@path}/quotes_app/app/assets/images/*")
	system("rm #{@path}/quotes_app/app/views/gallery/*")
end

not_used_req_array = not_used_req_result.to_a
ind = rand(not_used_req_count)
quote_text = not_used_req_array[ind][1]
quote_author = not_used_req_array[ind][2]

#quote_text = "\"" + quote_text.strip + "\""
quote_text_img = "\"" + quote_text.strip + "\""

#the folling tweet_to_quote uses quotation marks
tweet_to_quote = "\"" + quote_text.strip + "\"" + " " + quote_author

# Mark the used quote as 'used' in the database
q_text_for_db = quote_text.gsub(/'/, "''")
update_req = "UPDATE #{@db_table} SET quote_status = 'used' WHERE quote_text = '#{q_text_for_db}'"
db_client.query(update_req)

# Close the connection to the database
db_client.close

#--------------------------- Create a picture with the quote----------------------------------

img_count = @all_images.size

# Randomly selects a background image
i = rand(img_count)
chosen_img = "#{@img_dic[i]}"

img = ImageList.new("#{chosen_img}")
img_width = @all_images[chosen_img]["img_width"]
img_height = @all_images[chosen_img]["img_height"]
row_height = @all_images[chosen_img]["row_height"]
qt_pointsize = @all_images[chosen_img]["qt_pointsize"]
qa_pointsize = @all_images[chosen_img]["qa_pointsize"]
text_font = @all_images[chosen_img]["font"]
fill_color = @all_images[chosen_img]["fill"]
max_row_length = @all_images[chosen_img]["row_length"]


qt_length = quote_text_img.length

# Checks the metrics of the text of the quotation
def get_all_qt_metrics(pic_width, pic_height, text, qt_pointsize, font, color)
	test_pic = Image.new(pic_width, pic_height)
	test_draw = Draw.new
	test_draw.annotate(test_pic, 0, 0, 50, 100, text) do
		self.font = font
		self.pointsize = qt_pointsize
		self.fill = color
		self.stroke = 'none'
	end

	return test_draw.get_type_metrics(test_pic, text)
end

# Checks the metrics of the author text of the quotation
def get_all_qa_metrics(pic_width, pic_height, text, qa_pointsize, font, color)
	test_pic = Image.new(pic_width, pic_height)
	test_draw = Draw.new
	test_draw.annotate(test_pic, 0, 0, 50, 100, text) do
		self.font = font
		self.pointsize = qa_pointsize
		self.fill = color
		self.stroke = 'none'
	end

	return test_draw.get_type_metrics(test_pic, text)
end

# Places text of the quotation on the image
def draw_text_on_pic(img, img_draw, qt_x_offset, qt_y_offset, qt_text, qt_pointsize, font, color)
	img_draw.annotate(img, 0, 0, qt_x_offset, qt_y_offset, qt_text) do 
		self.font = font
		self.pointsize = qt_pointsize
		self.fill = color
		self.stroke = 'none'
	end

end

# Places author of the quotation on the image
def draw_author_on_pic(img, img_draw, qa_x_offset, qa_y_offset, qt_author, qa_pointsize, font, color)
	img_draw.annotate(img, 0, 0, qa_x_offset, qa_y_offset, qt_author) do 
		self.font = font
		self.pointsize = qa_pointsize
		self.fill = color
		self.stroke = 'none'
	end
end

# If the quote is short enough to be displayed on a single line
if qt_length <= max_row_length  #41
	# Prepare the image and place text on it

	qt_metrics = get_all_qt_metrics(img_width, img_height, quote_text_img, qt_pointsize, text_font, fill_color)
	qt_width = qt_metrics['width']
	qt_height = qt_metrics['height']
	all_images_qt_x_offset = @all_images[chosen_img]["qt_x_offset"]
	all_images_qt_y_offset = @all_images[chosen_img]["qt_y_offset"]

	if all_images_qt_x_offset.is_a?(Integer)
		qt_x_offset = all_images_qt_x_offset
	else
		qt_x_offset = (img_width - qt_width)/2
	end
	
	if all_images_qt_y_offset.is_a?(Integer)
		qt_y_offset = all_images_qt_y_offset
	else
		qt_y_offset = (img_height - qt_height)/2
	end

	qa_metrics = get_all_qa_metrics(img_width, img_height, quote_author, qa_pointsize, text_font, fill_color)
	qa_width = qa_metrics['width']
	qa_height = qa_metrics['height']
	qa_x_offset = (img_width - qt_x_offset - qa_width)
	qa_y_offset = (qt_y_offset + qt_height + 40)
	
	img_draw = Draw.new
	draw_text_on_pic(img, img_draw, qt_x_offset, qt_y_offset, quote_text_img, qt_pointsize, text_font, fill_color)
	draw_author_on_pic(img, img_draw, qa_x_offset, qa_y_offset, quote_author, qa_pointsize, text_font, fill_color)

else # Quote is too long for a single line (qt_length > 41) and quote must be splitted into rows
	qt_array = quote_text_img.split(/ /)
	rows = Array.new()
	row_text = ""

	qt_array.each do |word|
		row_length = row_text.length
		word_length = word.length
 
		if row_length + word_length <= max_row_length
			if row_length + word_length <= (max_row_length - 1)
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

	#-------------Quote of multiple rows: Place the quote on the image--------------
	all_images_row_y_offset_start = @all_images[chosen_img]["row_y_offset_start"]

	if all_images_row_y_offset_start.is_a?(Integer)
		row_y_offset_start = all_images_row_y_offset_start
	else
		row_y_offset_start = (img_height - (row_height*rows.size + 50.0*(rows.size-1))) / 2
	end
	row_x_offset_min = 0
	row_x_offset_array = []
	last_row_y_offset = 0
	img_draw = Draw.new

	rows.each_with_index do |row, index|
		
		row_metrics = get_all_qt_metrics(img_width, img_height, row, qt_pointsize, text_font, fill_color)
		row_width = row_metrics['width']
		all_images_row_x_offset = @all_images[chosen_img]["row_x_offset"]

		if all_images_row_x_offset.is_a?(Integer)
			row_x_offset = all_images_row_x_offset
		else
			row_x_offset = (img_width - row_width)/2
		end

		row_x_offset_array << row_x_offset

		row_y_offset = row_y_offset_start + (row_height + 50) * index

		draw_text_on_pic(img, img_draw, row_x_offset, row_y_offset, row, qt_pointsize, text_font, fill_color)
		last_row_y_offset = row_y_offset
	end

	row_x_offset_min = row_x_offset_array.min


	#-------------Place the author of the quote on the image-----------------
	
	qa_metrics = get_all_qa_metrics(img_width, img_height, quote_author, qa_pointsize, text_font, fill_color)
	qa_width = qa_metrics['width']
	qa_height = qa_metrics['height']
	all_images_qa_x_offset = @all_images[chosen_img]["qa_x_offset"]

	if all_images_qa_x_offset.is_a?(Integer)
		qa_x_offset = all_images_qa_x_offset
	elsif @all_images[chosen_img].key?("qa_x_endpoint")
		qa_x_offset = @all_images[chosen_img]["qa_x_endpoint"] - qa_width
	else
		qa_x_offset = img_width - row_x_offset_min - qa_width
	end
	
	qa_y_offset = last_row_y_offset + row_height + 30

	draw_author_on_pic(img, img_draw, qa_x_offset, qa_y_offset, quote_author, qa_pointsize, text_font, fill_color)

end

img.write("#{@path}/img_to_post_general_walls.jpg")

# #--------------------Tweet the picture---------------

weekday = Time.new.wday

case weekday
	when 1 #Monday
		hashtags = "#MondayMotivation"
	when 2 #Tuesday
		hashtags = "#TuesdayThoughts"
	when 3 #Wednesday
		hashtags = "#WednesdayWisdom"
	when 4 #Thursday
		hashtags = "#ThursdayThoughts"
	when 5 #Friday
		hashtags = "#FridayMotivation"
	when 6 #Saturday
		hashtags = "#SaturdayMotivation"
	else # Sunday
		hashtags = "#SundayMotivation"
end

# Updates the files for the website
#1. step: Check the number of files --> count one up -> copy the image in the folder under the name of Zaehler.jpg
#2. step: Create a new file in gallery folder: Zahler.html.erb
#3. step: Fill that file according to the scheme
num_of_img = Dir["#{@path}/quotes_app/app/assets/images/*"].size
	system("cp img_to_post_general_walls.jpg #{@path}/quotes_app/app/assets/images/#{num_of_img+1}.jpg")
	system("touch #{@path}/quotes_app/app/views/gallery/#{num_of_img+1}.html.erb")
	f = File.open("#{@path}/quotes_app/app/views/gallery/#{num_of_img+1}.html.erb", "a+")
	f.write("<% provide(:title, \"#{quote_author.tr('()', '')}\") %>\n\n")
	f.write('<div class="single-quote-img">')
	f.write("\n")
	f.write("<%= link_to image_tag(\"#{num_of_img+1}.jpg\", alt:\"quote by #{quote_author.tr('()', '')}\", class: \"quotes-img\"), image_url('#{num_of_img+1}.jpg'), target: :_blank %>\n")
	f.write("</div>")
# exit


# Connects to the Twitter account
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = @consumer_key
    config.consumer_secret     = @consumer_secret
    config.access_token        = @access_token
    config.access_token_secret = @access_token_secret
  end

# Tweets the quote
client.update_with_media("#{hashtags}", File.new("#{@path}/img_to_post_general_walls.jpg"))

# Toots the new quote - mastodon
#system("ruby #{@path}/mastodon-bot.rb")
