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

get '/shelter_items/:id' do
  @shelter = Shelter.find(params[:id])

  @shelter_items = @shelter.items.all

  erb :shelter_items_list
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
    @shelter.items.create(name: params[:name], price: params[:place], image_url: params[:image_url], item_code: params[:item_code])
    p "作成しました．"
  end
  redirect '/'
end


