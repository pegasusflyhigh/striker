class Round < ApplicationRecord
  PINS = 10

  belongs_to :game
  belongs_to :player
  has_one :previous, class_name: 'Round', foreign_key: :previous_id, dependent: :destroy

  validates_uniqueness_of :number, scope: [:player_id, :game_id]
  validate :max_score_for_non_strike_or_spare
  validates :scores, length: { maximum: 3 }

  def strike?
    scores.first == PINS
  end

  def spare?
    !strike? && scores.first(2).collect(&:to_i).sum == PINS
  end

  def first_round?
    number.zero?
  end

  def last_round?
    number == Game::MAX_ROUNDS - 1
  end

  private

  def max_score_for_non_strike_or_spare
    return true if strike? || spare?

    errors.add(:scores, I18n.t('round.errors.max_score')) unless valid_scores? && scores.collect(&:to_i).sum < PINS
    false
  end

  def valid_scores?
    return true if scores.empty? || strike? || spare?

    scores.all? { |i| i.is_a?(Integer) }
  end
end
