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

#登録とかログイン，ログアウト周り
##ユーザの新規登録，
get '/user/signup' do
  erb :'/login/user/sign_up'
end

post '/user/signup' do
  p params
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

##ユーザのログイン
get '/user/signin' do
  erb :'/login/user/sign_in'
end

post '/user/signin' do
  user = User.find_by(email: params[:email])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
    session[:type] = "user"
  end
  redirect '/'
end

##避難所の新規登録
get '/shelter/signup' do
  erb :'/login/shelter/sign_up'
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

##避難所のログイン
get '/shelter/signin' do
  erb :'/login/shelter/sign_in'
end

post '/shelter/signin' do
  shelter = Shelter.find_by(email: params[:email])
  if shelter && shelter.authenticate(params[:password])
    session[:shelter] = shelter.id
    session[:type] = "shelter"
  end

  redirect '/'
end

##ユーザ，避難所のログアウト
get '/signout' do
  session[:shelter] = nil
  session[:user] = nil
  session[:type] = nil
  redirect '/'
end

#ユーザ，避難所共通の処理
##現在登録されている避難所一覧を表示
get '/show/shelters' do
  @shelters = Shelter.all
  erb :'/shelter/show_shelters'
end

##現在登録されている必要物資一覧を表示
get '/show_items' do
  @items = Item.all
  @shelters = Shelter.all
  erb :'item/show_items'
end

##各避難所が欲しがっている物資一覧を表示
get '/shelter_items/:id' do
  @shelter = Shelter.find(params[:id])
  @shelter_items = @shelter.items.all
  erb :'/shelter/shelter_items_list'
end

#ユーザのみの処理
##そのユーザが支援表明している物資一覧表示
get '/user/item_list' do
  @user = User.find(session[:user])
  @shelter_items = @user.shelter_items.all
  #このshelter_itemsに入ってるのはidだけ
  #ここ汚い処理してる
  erb :'item/item_list'
end


#避難所のみの処理
##自分の避難所を支援してくれる人の一覧表示
get '/support_list' do 
  @shelter = Shelter.find(session[:shelter])
  @shelter_items = @shelter.items.all
  erb :'/shelter/support_list'
end

##必要物資の検索画面
get '/search_item' do
  erb :'/item/search_item'
end

##必要物資検索結果画面
post '/search_result' do
  @keyword = params[:keyword]
  @items = RakutenWebService::Ichiba::Item.search(:keyword => @keyword)
  p @items.first
  erb :'/item/search_result'
end

##必要物資登処理
post '/add_want' do

  @shelter = Shelter.find(session[:shelter])
  @item = Item.find_by(item_code: params[:item_code])

  if @item
    #Itemテーブルにすでに登録されるかつ，避難所と物資が結びついている時
    if @shelter.items.find_by(item_code: params[:item_code])
    else 
      #Itemテーブルに登録されているが結びついていない時はリレーション追加
      @item.shelters << @shelter
    end
  else
    #Itemテーブルに登録されていない場合は追加
    @shelter.items.create(name: params[:name], price: params[:place], image_url: params[:image_url], item_code: params[:item_code])
  end
  redirect '/'
end

##自分の避難所を支援してくれる人一覧を取得
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

