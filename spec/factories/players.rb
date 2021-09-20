FactoryBot.define do
  factory :player do
    name { "MyString" }
    association :game
  end
end
