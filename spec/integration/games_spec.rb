# spec/integration/pets_spec.rb
require 'swagger_helper'

describe 'Games API' do
  path '/start_game' do
    post 'Creates a game' do
      tags 'Games'
      consumes 'application/json'
      parameter name: :game, in: :body, schema: {
        type: :object,
        properties: {
          game: {
            properties: {
              players_attributes: {
                type: :object,
                example: [
                  { name: 'Jim' },
                  { name: 'Pam' }
                ]
              }
            }
          }
        }
      }

      response '201', 'Game created' do
        let(:game) { { players_attributes: [{ name: 'Pam' }, { name: 'Jim' }] } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:game) { { players: [{ name: 'Pam' }, { name: 'Jim' }] } }
        run_test!
      end
    end
  end

  path '/get_scores/{id}' do
    get 'Retrieves a game' do
      tags 'Games'
      produces 'application/json', 'application/xml'
      parameter name: :id, in: :path, type: :string

      response '200', 'name found' do
        schema type: :object,
               properties: { id: { type: :integer } }
        let(:id) { Game.create(status: 'started').id }
        run_test!
      end

      response '404', 'Game not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
