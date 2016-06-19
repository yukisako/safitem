class CreateShelters < ActiveRecord::Migration
  def change
    create_table :shelters do |t|
      t.string :shelter_name
      t.string :home_adress
      t.string :email
      t.string :password_digest
      t.string :phone
      t.string :representative_name

      t.timestamps null: false
      
      t.index :email, unique: true  #メールアドレスにインデックスを付与してユニーク制約をかける
    end
  end
end
