Rails.application.routes.draw do

  root 'static_pages#home'
  
  get '/about', to: 'static_pages#about'
  get '/imprint', to: 'static_pages#imprint'
  get '/privacy_notice', to: 'static_pages#privacy_notice'
  get '/contact', to: 'static_pages#contact'

  get '/gallery', to: 'static_pages#full_gallery'
  get '/gallery/:id', to: 'gallery#show_quote'
  get '/gallery/*id/download', to: 'gallery#download_quote'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

end
