# app/services/score_updater.rb

class ScoreUpdater
  include ActiveModel::Validations

  validates_numericality_of :pins, only_integer: true
  validates :roll, inclusion: { in: [1, 2, 3], message: I18n.t('roll.errors.invalid') }
  validates_presence_of :round, :pins, :roll

  validate :valid_game, :valid_round, :valid_pins

  def initialize(args)
    @round = args[:round]
    @pins = args[:pins]
    @roll = args[:roll]
  end

  attr_reader :roll, :pins, :round

  def call
    return unless valid?

    save_scores_for_current_round &&
      save_scores_for_previous_rounds &&
      update_game_status
  end

  private

  def save_scores_for_current_round
    round.scores[roll - 1] = pins
    add_empty_scores
    return true if round.save!

    errors.add(:base, round.errors.messages)
    false
  end

  def save_scores_for_previous_rounds
    return true if round.first_round?

    current_round = round
    previous_round = current_round.previous

    while previous_round.present? && previous_round.scores.any?(&:nil?)
      assign_scores_to_previous_strike(previous_round, current_round)
      assign_scores_to_previous_spare(previous_round, current_round)
      previous_round.save!

      current_round = previous_round
      previous_round = current_round.previous
    end
    true
  end

  def valid_game
    return true if round.blank? || round.game.status == 'started'

    errors.add(:base, I18n.t('game.errors.finished_game'))
    false
  end

  def valid_pins
    return true unless [round, roll, pins].all?(&:present?) && !round.try(:first_round?)
    return true if round.previous.scores.present? && first_roll?

    errors.add(:base, I18n.t('round.errors.invalid_score')) if round.scores[roll - 1].blank?
    false
  end

  def valid_round
    return true unless round.present? && round_completed?

    errors.add(:base, I18n.t('round.errors.already_finished'))
    false
  end

  def round_completed?
    return true if round.blank? || round.number == 9

    round.strike? || round.spare?
  end

  def add_empty_scores
    round.scores.push("?", "?") if first_roll? && round.strike?
    round.scores.push("?") if second_roll? && round.spare?
  end

  def assign_scores_to_previous_strike(previous_round, current_round)
    return unless previous_round.strike?

    previous_round.scores[1] ||= current_round.scores.first
    previous_round.scores[2] ||= current_round.scores.second
  end

  def assign_scores_to_previous_spare(previous_round, current_round)
    return unless previous_round.spare?

    previous_round.scores[2] ||= current_round.scores.first
  end

  def update_game_status
    return true unless round.last_round?

    game = round.game
    game.status = 'finished'
    game.save!
  end

  def first_roll?
    roll == 1
  end

  def second_roll?
    roll == 2
  end
end
