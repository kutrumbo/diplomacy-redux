Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'application#index'

  namespace :api do
    resources :areas, only: [:index]
    resources :orders, only: [] do
      post 'adjudicate', on: :collection
    end
  end
end
