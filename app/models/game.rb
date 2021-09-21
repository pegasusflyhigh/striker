class Game < ApplicationRecord
  MAX_ROUNDS = 10
  STATUSES = %w[started finished].freeze

  has_many :players, dependent: :destroy
  has_many :rounds, -> { order(created_at: :asc) }, before_add: :validate_rounds_limit, dependent: :destroy

  validates :status, inclusion: { in: STATUSES }
  accepts_nested_attributes_for :players

  def as_json(_options = {})
    super(only: [:id, :status],
          include: { players: { only: [:id, :name],
                                methods: :total_score,
                                include: { rounds: { only: [:id, :number, :scores] } } } })
  end

  private

  def validate_rounds_limit(_round)
    raise I18n.t 'game.errors.max_rounds_error' if rounds.size >= MAX_ROUNDS
  end
end
