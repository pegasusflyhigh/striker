Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  resources :games, shallow: true do
    resources :players, shallow: true do
      resources :rounds, only: [:update]
    end
  end

  match 'start_game', to: 'games#create', via: :post
  match 'get_scores/:id', to: 'games#show', via: :get
end
