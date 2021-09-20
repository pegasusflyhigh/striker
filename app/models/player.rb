class Player < ApplicationRecord
  has_many :rounds
  belongs_to :game
end
