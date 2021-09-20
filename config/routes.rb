Rails.application.routes.draw do
  resources :games do
    resources :players do
      resources :rounds
    end
  end

  match 'start_game', to: 'games#create', via: :post
  match 'get_scores/:id', to: 'games#show', via: :get
end
