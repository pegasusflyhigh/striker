require 'rails_helper'

RSpec.describe Player, type: :model do
  let(:game) { create(:game) }

  context 'associations' do
    it { should have_many(:rounds) }
    it { should belong_to(:game) }
  end

  context 'callbacks' do
    context 'after_create' do
      it "creates #{Game::MAX_ROUNDS} rounds for the player" do
        player = build(:player, game_id: game.id)
        expect { player.save! }.to change { Round.count }.by(Game::MAX_ROUNDS)
      end
    end
  end

  describe '.total_score' do
    let(:player) { create(:player, game_id: game.id) }

    before do
      first_round = player.rounds.first
      first_round.update(scores: [2, 5])
      second_round = player.rounds.second
      second_round.update(scores: [4, 3])
    end

    it 'returns sum of scores in all rounds in a game' do
      expect(player.total_score).to eq 14
    end
  end
end
