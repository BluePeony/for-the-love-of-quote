
# Adds new quotes to the database

require 'mysql2'
require 'facets'
require '/home/anna/ruby/Projekte/twitter_quotes_bot/general/config_general.rb'

puts "Hi, here you can add a new quote to the quotes database."
puts "Enter :quit to finish and leave the program."
puts "Please note that quotes that are longer than 280 characters can't be included in the database. But you will get a note!"
puts "DO NOT use any quotation marks. Just type in the text of the quote first and press ENTER. Then you can add the author."
puts

# Connects to the Mysql database and gets the last id
db_client = Mysql2::Client.new(:host => @host, :username => @username, :password => @pw, :database => @database)
max_id_query = "SELECT MAX(id) FROM #{@db_table}"
max_id_sql_query = db_client.query(max_id_query)
max_id = 0
max_id_sql_query.each do |row|
	max_id = row["MAX(id)"]
end
if !max_id.is_a? Integer
	max_id = 0
end

finished = false

while !finished do 
	similarity_found = false
	print "quote text: "
	q_text = gets
	if q_text.chomp == ":quit" # If user wants to finish
		finished = true
	else # User entered something
		q_text = q_text.chomp
		print "author: "
		q_author = "(" + gets.chomp + ")"
		q_length = q_text.length + 1 + q_author.length


		if q_length <= 278 # 2 slots for ""
			# Checks if the quote is already in the database
			q_text_for_db = q_text.gsub(/'/, "''")
			q_author_for_db = q_author.gsub(/'/, "''")

			select_req = "SELECT quote_text FROM #{@db_table} WHERE quote_author = '#{q_author_for_db}'"
			select_ans = db_client.query(select_req)

			if select_ans.count == 0
				# There are no quotes by this author in the database yet; the quote can be added
				max_id += 1
				insert_req = "INSERT INTO #{@db_table} (id, quote_text, quote_author, quote_length, quote_status) VALUES ('#{max_id}', '#{q_text_for_db}', '#{q_author_for_db}', '#{q_length}', 'not used')"
				db_client.query(insert_req)
				puts "Quote added to the database!"
				puts
			else
				# Quotes by this author already exist in the database
				select_ans.each do |row|
					sim_result = row['quote_text'].similarity(q_text)
					if sim_result >= 0.8 # Similarity exists
						puts
						puts "There is a similar quote in the database!"
						puts "Quote from the database (Q1): #{row['quote_text']}"
						puts "The new quote (Q2): #{q_text}"
						puts "Should the new quote (Q2) be added to the database despite the similarity? -> type 'add'"
						puts "Should the existing quote be replaced by the new quote? -> type 'replace'"
						puts "If nothing should be done -> type 'no'"
						user_ans = gets.chomp
						if user_ans == "add"
							max_id += 1
							insert_req = "INSERT INTO #{@db_table} (id, quote_text, quote_author, quote_length, quote_status) VALUES ('#{max_id}', '#{q_text_for_db}', '#{q_author_for_db}', '#{q_length}', 'not used')"
							db_client.query(insert_req)
							similarity_found = true
							puts "Quote added to the database."
							break
						elsif user_ans == "replace"
							#max_id += 1
							replace_req = "UPDATE #{@db_table} SET quote_text = REPLACE(quote_text, '#{row['quote_text']}', '#{q_text}')"
							db_client.query(replace_req)
							similarity_found = true
							puts "The existing quote in the database has been replaced my the newly entered one."
							break
						elsif user_ans == "no"
							similarity_found = true
							puts 
							break
						end
						puts
					end
				end
				
				# No similar quote by this author in the database; quote can be added.
				if similarity_found == false
					max_id += 1
					insert_req = "INSERT INTO #{@db_table} (id, quote_text, quote_author, quote_length, quote_status) VALUES ('#{max_id}', '#{q_text_for_db}', '#{q_author_for_db}', '#{q_length}', 'not used')"
					db_client.query(insert_req)
					puts "Quote added to the database"
					puts
				end
			end

		else
			puts "Ups! Your quote is too long. Max 280 chars are allowed. Sorry, buddy."
		end
	end
end
