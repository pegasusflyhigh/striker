require 'rails_helper'

RSpec.describe "Rounds", type: :request do
  let(:game) { create(:game) }
  let(:player) { create(:player, game_id: game.id) }
  let(:first_round) { player.rounds.first }

  def update_data(pins, roll)
    { round: { pins: pins, roll: roll } }
  end

  describe 'PUT /update' do
    it 'should update with correct data' do
      put "/rounds/#{first_round.id}", params: update_data(2, 1)

      response_body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(response_body.dig('players', 0, 'rounds', 0, 'scores')).to eq [2]
    end

    it 'should return error with incorrect data param' do
      put "/rounds/#{first_round.id}", params: update_data(2, 4)

      response_body = JSON.parse(response.body)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body.dig('error', 'roll', 0)).to eq I18n.t('roll.errors.invalid')
    end
  end
end
