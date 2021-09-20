class Round < ApplicationRecord
  belongs_to :game
  belongs_to :player
  has_one :previous, class_name: 'Round', foreign_key: :previous_id, dependent: :destroy

  validates_uniqueness_of :number, scope: [:player_id, :game_id]
end
