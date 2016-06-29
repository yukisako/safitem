class CreateUserItems < ActiveRecord::Migration
  def change
      create_table :user_items do |t|
      t.references :user, index: true, null: false
      t.references :shelter_item, index: true, null: false
      t.timestamps null: false
    end
  end
end
