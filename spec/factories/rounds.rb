FactoryBot.define do
  factory :round do
    score { "MyText" }
    association :player
    association :game
  end
end
