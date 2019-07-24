Rails.application.routes.draw do
  root 'application#index'

  namespace :api do
    resources :plants, only: [:create, :index] do
      resources :waterings, only: :create
    end
    resources :users, only: :create
  end

  get '*destination', to: 'application#index'
end
