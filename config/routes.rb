Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'application#index'
  get '/sandbox', to: 'application#index'
  get '/games/:id', to: 'application#index'

  namespace :api do
    resources :areas, only: [:index]
    resources :games, only: [:show]
    resources :orders, only: [] do
      post 'adjudicate', on: :collection
    end
  end
end
