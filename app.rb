require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'open-uri'
require 'sinatra/json'
require 'rakuten_web_service'

enable :sessions

require './models/shelter.rb'

get '/' do 
  if session[:shelter]
    @name = Shelter.find(session[:shelter]).shelter_name
  elsif session[:user]
    @name = User.find(session[:user]).user_name
  end
  erb :index
end

get '/shelter/signin' do
  erb :'/shelter/sign_in'
end

get '/user/signin' do
  erb :'user/sign_in'
end

get '/shelter/signup' do
  erb :'shelter/sign_up'
end

get '/user/signup' do
  erb :'user/sign_up'
end

get '/user/item_list' do
  @user = User.find(session[:user])
  @shelter_items = @user.shelter_items.all
  #このshelter_itemsに入ってるのはidだけ
  #ここ汚い処理してる
  


  erb :'user/item_list'
end


get '/show/shelters' do
  @shelters = Shelter.all
  erb :show_shelters
end

get '/shelter_items/:id' do
  @shelter = Shelter.find(params[:id])

  @shelter_items = @shelter.items.all

  erb :shelter_items_list
end

post '/shelter/signup' do
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
    session[:type] = "shelter"
  end

  redirect '/'
end

post '/user/signup' do
  @user = User.create({
    email: params[:email],
    password: params[:password],
    password_confirmation: params[:password_confirmation],
    phone: params[:phone],
    user_name: params[:user_name],
    home_adress: params[:home_adress]
    })

  #persisted?はユーザが保存済みかをチェックするメソッド
  if @user.persisted?
    session[:user] = @user.id
    session[:type] = "user"
  end

  redirect '/'
end

post '/shelter/signin' do
  shelter = Shelter.find_by(email: params[:email])
  if shelter && shelter.authenticate(params[:password])
    session[:shelter] = shelter.id
    session[:type] = "shelter"
  end

  redirect '/'
end

post '/user/signin' do
  user = User.find_by(email: params[:email])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
    session[:type] = "user"
  end
  redirect '/'
end

get '/signout' do
  session[:shelter] = nil
  session[:user] = nil
  session[:type] = nil
  redirect '/'
end

get '/show_items' do
  @items = Item.all
  @shelters = Shelter.all
  erb :show_items
end


get '/search_item' do
  erb :search_item
end

post '/search_result' do
  @keyword = params[:keyword]
  @items = RakutenWebService::Ichiba::Item.search(:keyword => @keyword)
  p @items.first
  erb :search_result
end

post '/add_want' do

  @shelter = Shelter.find(session[:shelter])
  @item = Item.find_by(item_code: params[:item_code])

  #Active Recordから返ってきた避難所情報をハッシュに変換(JSONに変換してからハッシュに変換)
  shelter_hash = JSON.parse(@shelter.to_json)
  p shelter_hash
  p @shelter.hash
  if @item
    #Itemテーブルにすでに登録されるかつ，避難所と物資が結びついている時
    if @shelter.items.find_by(item_code: params[:item_code])
      p "すでに結びついてるよ"
    else 
      #Itemテーブルに登録されているが結びついていない時はリレーション追加
      @item.shelters << @shelter
      p "結びつけた"
    end
  else
    #Itemテーブルに登録されていない場合は追加
    #これ上でやったハッシュで書けばいいのでは？
    @shelter.items.create(name: params[:name], price: params[:place], image_url: params[:image_url], item_code: params[:item_code])
    p "作成しました．"
  end
  redirect '/'
end


post '/support' do
  p params[:item_id]
  p params[:shelter_id]
  #これ，item_idとshelter_idの２つでshelter_itemテーブルに検索かけてるけど，うまいことidとりたい．
  item = ShelterItem.find_by(item_id: params[:item_id], shelter_id: params[:shelter_id])
  @user = User.find(session[:user])
  p @user
  p item
  item.users << @user
  redirect '/'
end

