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
end

