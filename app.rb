require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'open-uri'
require 'sinatra/json'
require 'rakuten_web_service'

enable :sessions

require './models/shelter.rb'

get '/' do
  erb :index
end

get '/signin' do
  erb :sign_in
end

get '/signup' do
  erb :sign_up
end

post '/signup' do
  @shelter = Shelter.create({
    email: params[:email],
    password: params[:password],
    password_confirmation: params[:password_confirmation],
    phone: params[:phone],
    shelter_name: params[:shelter_name],
    home_adress: params[:home_adress],
    representative_name: params[:representative_name]
    })

  #persisted?はユーザが保存済みかをチェックするメソッド
  if @shelter.persisted?
    session[:shelter] = @shelter.id
  end

  redirect '/'
end

post '/signin' do
  shelter = Shelter.find_by(email: params[:email])
  if shelter && shelter.authenticate(params[:password])
    session[:shelter] = shelter.id
  end

  redirect '/'
end

get '/signout' do
  session[:shelter] = nil
  redirect '/'
end


#とりあえず楽天apiのテスト
get '/rakuten' do
  @items = RakutenWebService::Ichiba::Item.search(:keyword => 'Ruby')
  erb :rakuten
end

post '/search' do
  @items = RakutenWebService::Ichiba::Item.search(:keyword => params[:item_name])

  @shelter = Shelter.find(session[:shelter])
  item = @items.first
  p @shelter
  @shelter.items.create(name: item['itemName'], price: item.price, image_url: item['mediumImageUrls'].first['imageUrl'])
  erb :rakuten
end
