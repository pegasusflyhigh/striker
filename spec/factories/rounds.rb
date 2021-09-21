FactoryBot.define do
  factory :round do
    scores { [4, 5] }
    association :player
    association :game
  end
end
