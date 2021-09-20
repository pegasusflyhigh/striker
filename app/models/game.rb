class Game < ApplicationRecord
  MAX_ROUNDS = 10
  STATUSES = %w[started finished cancelled].freeze

  has_many :players, dependent: :destroy
  has_many :rounds, before_add: :validate_rounds_limit, dependent: :destroy

  validates :status, inclusion: { in: STATUSES }

  private

  def validate_rounds_limit(_round)
    raise I18n.t 'game.errors.max_rounds_error' if rounds.size >= MAX_ROUNDS
  end
end
