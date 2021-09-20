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
end
