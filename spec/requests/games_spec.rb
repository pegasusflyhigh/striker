require 'rails_helper'

RSpec.describe "Games", type: :request do
  let(:game) { create(:game) }

  def create_params(player_names)
    players = []
    player_names.each do |name|
      players << { name: name }
    end

    { game: { players_attributes: players } }
  end

  describe 'POST /create' do
    it 'should update with correct data' do
      post '/games', params: create_params(%w[Jim Tanya])

      response_body = JSON.parse(response.body)

      expect(response).to have_http_status(:created)
      expect(response_body['status']).to eq 'started'
      expect(response_body['players'].size).to eq 2
    end
  end

  describe 'GET /show' do
    it 'should return required game record' do
      get "/games/#{game.id}"

      response_body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(response_body['status']).to eq 'started'
    end

    it 'should return error with invalid id' do
      allow_any_instance_of(Game).to receive(:save).and_return(false)

      get '/games/1'

      response_body = JSON.parse(response.body)

      expect(response).to have_http_status(:not_found)
      expect(response_body['error']).to eq I18n.t('game.errors.not_found')
    end
  end
end
