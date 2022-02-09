class GalleryController < ApplicationController
  def gallery
  end

  def show_quote
  	render "#{params[:id]}"
  end

  def download_quote
  	send_file("#{Rails.root.join('app', 'assets', 'images', "/home/anna/ruby/Projekte/twitter_quotes_bot/general/quotes_app/app/assets/images/big_sized_images/#{params[:id]}.jpg")}")
  end
end
