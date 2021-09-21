require 'rails_helper'

RSpec.describe Round, type: :model do
  let(:game) { create(:game) }
  let(:player) { create(:player, game_id: game.id) }
  let(:round) { player.rounds.second }
  let(:first_round) { player.rounds.first }

  context 'associations' do
    it { should belong_to(:player).class_name('Player') }
    it { should belong_to(:game).class_name('Game') }
    it { should have_one(:previous) }
  end

  context 'validations' do
    it { should validate_uniqueness_of(:number).scoped_to([:player_id, :game_id]) }

    it 'validates the size of scores is at most 3' do
      round.scores = [1, 2, 3]
      expect(round).to be_valid

      round.scores = [1, 2, 3, 4]
      expect(round).to be_invalid
    end

    describe 'valid_scores?' do
      context 'returns true' do
        it 'when round scores are empty' do
          empty_score_round = player.rounds.last
          expect(empty_score_round.scores).to eq []
          expect(empty_score_round.send(:valid_scores?)).to eq true
        end

        it 'when round is a strike' do
          first_round.scores = [10]

          expect(first_round.send(:valid_scores?)).to eq true
        end

        it 'when round is a spare' do
          first_round.scores = [6, 4]

          expect(first_round.send(:valid_scores?)).to eq true
        end
      end

      context 'returns false' do
        it 'when scores contain non integer value' do
          first_round.scores << "hey"

          expect(first_round.send(:valid_scores?)).to eq false
        end
      end
    end

    describe 'max_score_for_non_strike_or_spare' do
      context 'returns true' do
        it 'when it is a strike' do
          round.scores = [Round::PINS]
          expect(round.strike?).to eq true
          expect(round).to be_valid
        end

        it 'when it is a spare' do
          round.scores = [4, Round::PINS - 4]
          expect(round.spare?).to eq true
          expect(round).to be_valid
        end

        it "when it is not strike or spare and total score is less than #{Round::PINS}" do
          round.scores = [4, Round::PINS - 5]
          expect(round).to be_valid
        end
      end

      context 'returns false and adds error' do
        it "when it is not strike or spare and scores are non numeric" do
          round.scores = [4]
          round.scores << "?"

          expect(round).to be_invalid
          expect(round.errors[:scores]).to include(I18n.t('round.errors.max_score'))
        end

        it "when it is not strike or spare and total score is more than #{Round::PINS}" do
          round.scores = [4, Round::PINS - 2]
          expect(round).to be_invalid
          expect(round.errors[:scores]).to include(I18n.t('round.errors.max_score'))
        end
      end
    end
  end

  describe ".first_round?" do
    it 'returns true if it is the first round of the game' do
      expect(first_round.first_round?).to eq true
    end
  end

  describe ".last_round?" do
    it 'returns true if it is the last round of the game' do
      last_round = player.rounds.last

      expect(last_round.last_round?).to eq true
    end
  end

  describe ".strike?" do
    it 'returns true if given round is a strike' do
      first_round.scores = [10]
      expect(first_round.strike?).to eq true
    end
  end

  describe ".spare?" do
    it 'returns true if given round is a spare' do
      first_round.scores = [4, Round::PINS - 4]
      expect(first_round.spare?).to eq true
    end
  end
end
