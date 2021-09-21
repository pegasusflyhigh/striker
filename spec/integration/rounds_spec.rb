# spec/integration/pets_spec.rb
require 'swagger_helper'

describe 'Games API' do
  path '/rounds/{id}' do
    put 'Updates a round' do
      tags 'Rounds'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :round, in: :body, schema: {
        type: :object,
        properties: {
          round: {
            properties: {
              pins: {
                type: :integer,
                example: 4
              },
              roll: {
                type: :integer,
                example: 1
              }
            }
          }
        }
      }

      response '200', 'round updated' do
        let(:game) { create(:game) }
        let(:player) { create(:player, game_id: game.id) }
        let(:round) { { round: { pin: 4, roll: 1 } } }
        let(:id) { player.rounds.first.id }

        run_test!
      end

      response '422', 'invalid request' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
