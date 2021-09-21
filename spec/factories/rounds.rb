FactoryBot.define do
  factory :round do
    association :player
    association :game
  end
end
