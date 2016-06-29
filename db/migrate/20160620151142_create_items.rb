class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.timestamps null: false
      t.string :price
      t.string :image_url
      t.string :item_code
      t.string :item_url
    end
  end
end
