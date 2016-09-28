class CreateChats < ActiveRecord::Migration
  def change
  	create_table :chats do |t|
  		t.integer :shelter_id
  		t.integer :user_id
  		t.string :from
  		t.string :body
  		t.timestamps null: false
  	end
  end
end
