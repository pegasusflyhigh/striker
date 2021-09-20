class Player < ApplicationRecord
  has_many :rounds, dependent: :destroy
  belongs_to :game

  after_create :create_rounds

  private

  def create_rounds
    previous_round = nil
    Game::MAX_ROUNDS.times do |num|
      round = Round.new(number: num, game_id: game_id, player_id: id)
      round.previous = previous_round
      round.save!

      previous_round = round
    end
  end
end
