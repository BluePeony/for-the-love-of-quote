require 'rubygems'
require 'bundler/setup'
require 'mastodon'
require '/home/anna/ruby/Projekte/twitter_quotes_bot/general/img_init_general_walls.rb'
require '/home/anna/ruby/Projekte/twitter_quotes_bot/general/config_general.rb'

client = Mastodon::REST::Client.new(base_url: 'https://layer8.space/', bearer_token: '51d627261b92973d8c928464d5beba63ee003ca842fcd71ac6f530358e7ee000')
form = HTTP::FormData::File.new("#{@path}/img_to_post_general_walls.jpg")
media = client.upload_media(form)
status = ""
client.create_status(status, {:media_ids => [media.id]})
#m1 = client.upload_media("/home/anna/ruby/Projekte/twitter_quotes_bot/general/p1.jpg")
#client.create_status("Test!", [m1])
#puts m1
