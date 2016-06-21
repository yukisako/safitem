class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.timestamps null: false
      t.string :price
      t.string :image_url
    end
  end
end