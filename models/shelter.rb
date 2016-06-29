ActiveRecord::Base.establish_connection(
  ENV['DATABASE_URL']||'sqlite3:db/development.db')

class Shelter < ActiveRecord::Base
  has_secure_password

  #バリデーションに関しては後でもっと詳しくする
  validates :email,
    presence: true,
    format: {with:/.+@.+/}
  validates :password,
    length: {in: 5..10}

    has_many :shelter_item
    has_many :items, :through => :shelter_item
end

class Item < ActiveRecord::Base
  has_many :shelter_item
  has_many :shelters, :through => :shelter_item
end



class ShelterItem < ActiveRecord::Base
  belongs_to :shelter
  belongs_to :item
  has_many :user_items
  has_many :users, :through => :user_items
end

class User < ActiveRecord::Base
  has_secure_password
  has_many :user_items
  has_many :shelter_items, :through => :user_items
  #バリデーションに関しては後でもっと詳しくする
  validates :email,
    presence: true,
    format: {with:/.+@.+/}
  validates :password,
    length: {in: 5..10}
end

class UserItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :shelter_item
end

