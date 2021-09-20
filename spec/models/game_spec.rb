require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:game) { create(:game) }
  let(:player) { create(:player, game_id: game.id) }

  context 'associations' do
    it { should have_many(:players) }
    it { should have_many(:rounds) }
  end

  describe 'number of rounds' do
    it 'cannot be greater than the limit specified' do
      create_list(:round, Game::MAX_ROUNDS, game_id: game.id, player_id: player.id)
      new_round = create(:round, game_id: game.id, player_id: player.id)
      expect { game.rounds << new_round }.to raise_error(I18n.t('game.errors.max_rounds_error'))
    end
  end
end
