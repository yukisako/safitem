#Safitem

避難所で不足している品物一覧を表示し，避難所と物資支援をしてくれる企業，個人を結ぶサービス


#以下メモ

##設計

###ビュー構成

####index.erb

トップページ．とりあえず今はリンクを作っておくだけ．あとログイン，ログアウト画面とか．

####show_shelters.erb

避難所一覧ページ．ここから，各避難所が欲しがってる品物一覧のページに飛べるようにする．

####shelter_items.erb

避難所別の欲しがっているもの一覧表示ページ

####search_items.erb

商品検索画面

####search_result.erb

商品検索結果画面

####support_list.erb

自分の避難所を支援してくれる人を表示する画面．


###データベース構成

####避難所
名前，住所，メールアドレス(ログインで使う)，電話番号，避難者数，代表者名，id


####寄付者

名前，住所，メールアドレス，電話番号，id，ユーザタイプ


####中間テーブル

避難所idとitemsのid

####items

id,item_code,name,url,price

###デザイン構成

####テーマカラー

\#FC616E


##参考リンク

###ビューをフォルダ分け

http://qiita.com/shiopon01/items/4490ecc1deaef72823dd


##ToDo

###ログイン周り

バリデーション最適化

Twitterログイン

ログインしてなかったらトップページに戻してあげる処理

###個人情報更新

editのページ作ればいいだけなのでそんなむずくない

個人情報を表示するページも．

###楽天API

物品削除


