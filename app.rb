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

get '/show/shelters' do
  @shelters = Shelter.all
  erb :show_shelters
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
  @shelter = Shelter.find(session[:shelter])

  @items = Item.all

  @shelter_items = @shelter.items.all


  erb :show
end



post '/search' do
  @items = RakutenWebService::Ichiba::Item.search(:keyword => params[:item_name])
  erb :rakuten
end

post '/add_want' do
  @shelter = Shelter.find(session[:shelter])
  @shelter.items.create(name: params[:name], price: params[:place], image_url: params[:image_url])

  redirect '/rakuten'
end


