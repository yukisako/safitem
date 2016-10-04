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
  @items = Item.all
  erb :index
end

#登録とかログイン，ログアウト周り
##ユーザの新規登録，

def clear_alert()
  session[:alert] = nil
end

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
    session[:alert] = "ユーザ新規登録が成功しました"
  else
    session[:alert] = "ユーザ新規登録が失敗しました"
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
    session[:alert] = "ログインに成功しました"
  else
    session[:alert] = "ログインに失敗しました"
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
    session[:alert] = "避難所新規登録に成功しました"
  else
    session[:alert] = "避難所新規登録に失敗しました"
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
    session[:alert] = "ログインに成功しました"
  else
    session[:alert] = "ログインに失敗しました"
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
  if session[:user]
    @user = User.find(session[:user])
    @shelter_items = @user.shelter_items.all
    #このshelter_itemsに入ってるのはidだけ
    #ここ汚い処理してる
    erb :'item/item_list'
  else
    redirect '/'
  end
end

##決算画面
get '/user/pay' do
  if session[:user]
    @user = User.find(session[:user])
    @shelter_items = @user.shelter_items.all
    @sum = 0
    #このshelter_itemsに入ってるのはidだけ
    #ここ汚い処理してる
    erb :'item/pay_tmp'
  else
    redirect '/'
  end
end

post '/pay' do
  webpay = WebPay.new('test_secret_78B9iMcnyeoz8wx3aJ2lm0uF')

  webpay.charge.create(
    amount:   params["pay_price"],
    currency: "jpy",
    card: params["webpay-token"]
  )
  redirect '/'
end

get '/user/pay_fin' do
  erb :'item/pay_fin'
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
  session[:keyword] = params[:keyword] if params[:keyword]
  @keyword = session[:keyword]
  @items = RakutenWebService::Ichiba::Item.search(:keyword => @keyword)
  p @items.first
  erb :'/item/search_result'
end

get '/search_result' do
  session[:keyword] = params[:keyword] if params[:keyword]
  @keyword = session[:keyword]
  @items = RakutenWebService::Ichiba::Item.search(:keyword => @keyword)
  p @items.first
  erb :'/item/search_result'
end

##必要物資登処理
post '/add_want' do

  @shelter = Shelter.find(session[:shelter])
  @item = Item.find_by(item_code: params[:item_code])

  if @item
    #Itemテーブルにすでに登録されるかつ，避難所と物資が結びついている時はなにもしない
    unless @shelter.items.find_by(item_code: params[:item_code])
      #Itemテーブルに登録されているが結びついていない時はリレーション追加
      @item.shelters << @shelter
    end
  else
    #Itemテーブルに登録されていない場合は追加
    @shelter.items.create(name: params[:name], price: params[:price], image_url: params[:image_url], item_code: params[:item_code], item_url: params[:item_url])
  end

  #あとでjQueryでポスト処理を書き直す
  redirect back
end

##サポートする
post '/support' do
  p params[:item_id]
  p params[:shelter_id]
  #これ，item_idとshelter_idの２つでshelter_itemテーブルに検索かけてるけど，うまいことidとりたい．
  item = ShelterItem.find_by(item_id: params[:item_id], shelter_id: params[:shelter_id])
  @user = User.find(session[:user])
  p @user
  p item
  unless @user.shelter_items.find_by(item_id: params[:item_id])
    item.users << @user
  end
  redirect "/shelter_items/#{params[:shelter_id]}"
end

post '/support/:item_id' do
  @item = Item.find(params[:item_id])
  @shelters = @item.shelters.all
  erb :'/shelter/want_list'
end

post  '/show_support_users' do
  @item = Item.find(params[:item_id])
  p params[:item_id]
  p params[:shelter_id]
  item = ShelterItem.find_by(item_id: params[:item_id], shelter_id: params[:shelter_id])
  @users = item.users.all

  erb :'/shelter/show_support_users'
end

post '/support/delete/:id' do
  #ここ，紐付いてるのを一気に消す処理があったはず
  UserItem.find_by(shelter_item_id: params[:id], user_id: session[:user]).destroy
  redirect '/user/item_list'
end




# チャット機能
## 避難所チャットリスト
get '/shelter/chat_list' do
  # 支援表明してる人をリストとしてあげる
  @shelter = Shelter.find(session[:shelter])
  shelter_id = @shelter.id
  shelter_item = ShelterItem.find_by(shelter_id: shelter_id)
  if shelter_item != nil
    @users = shelter_item.users.all
  end 
  erb :'/chat/shelter_chat_list'
end

## ユーザチャットリスト
get '/user/chat_list' do
  # 支援表明している避難所をリストとしてあげる
  @user = User.find(session[:user])
  @shelter_items = @user.shelter_items
  @shelter_ids = []
  @shelter_items.each do |item|
    @shelter_ids.append(item.shelter_id)
  end
  @shelter_ids.uniq!
    erb :'/chat/user_chat_list'
end

## チャットルーム
get '/chat_room/:id' do
  # この辺もうちょっとなんとかならないですかね
  if session[:type] == "shelter"
    @shelter = Shelter.find(session[:shelter])
    @user = User.find(params[:id])
    @myself = @shelter.shelter_name
    @pertner = @user.user_name
  else
    @shelter = Shelter.find(params[:id])
    @user = User.find(session[:user])
    @myself = @user.user_name
    @pertner = @shelter.shelter_name
  end
  @chats = Chat.where(:shelter_id => @shelter.id, :user_id => @user.id).order("id asc").all
  erb :'/chat/chat_room'
end

## チャットの送信
post '/new' do
  Chat.create(:shelter_id => params[:shelter_id],
              :user_id => params[:user_id],
              :from => params[:from],
              :body => params[:body])
  if session[:type] == "shelter"
    id = params[:user_id]
  else 
    id = params[:shelter_id]
  end
  redirect "/chat_room/#{id}"
end

