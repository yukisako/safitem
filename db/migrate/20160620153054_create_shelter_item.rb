class CreateShelterItem < ActiveRecord::Migration
  def change
    create_table :shelter_items do |t|
      t.references :shelter, index: true, null: false
      t.references :item, index: true, null: false
      t.timestamps null: false
    end
  end
end
