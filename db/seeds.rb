#テストのためのデータベース登録

if User.count == 0
  User.create([
    {email: "user1@user.com", password: "11111",user_name: "user1", home_adress: "user1県user1市", phone: "111-1111-111", user_type: "user"},
    {email: "user2@user.com", password: "22222",user_name: "user2", home_adress: "user2県user2市", phone: "222-2222-222", user_type: "user"},
    {email: "user3@user.com", password: "33333",user_name: "user3", home_adress: "user3県user3市", phone: "333-3333-333", user_type: "company"}
    ])
end

if Shelter.count == 0
  Shelter.create([
    {email: "shelter1@shelter.com", password: "11111",shelter_name: "shelter1", home_adress: "shelter1県shelter1市", phone: "111-1111-111", representative_name: "太郎1"},
    {email: "shelter2@shelter.com", password: "22222",shelter_name: "shelter2", home_adress: "shelter2県shelter2市", phone: "222-2222-222", representative_name: "太郎2"},
    {email: "shelter3@shelter.com", password: "33333",shelter_name: "shelter3", home_adress: "shelter3県shelter3市", phone: "333-3333-333", representative_name: "太郎3"}
    ])
end

