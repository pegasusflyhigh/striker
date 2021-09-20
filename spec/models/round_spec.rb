require 'rails_helper'

RSpec.describe Round, type: :model do
  let(:round) { create(:round) }

  context 'associations' do
    it { should belong_to(:player).class_name('Player') }
    it { should belong_to(:game).class_name('Game') }
    it { should have_one(:previous) }
  end

  context 'validations' do
    it { should validate_uniqueness_of(:number).scoped_to([:player_id, :game_id]) }

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
end
