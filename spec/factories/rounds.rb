FactoryBot.define do
  factory :round do
    scores { "MyText" }
    association :player
    association :game
  end
end
