Rails.application.routes.draw do
  root 'application#index'

  namespace :api do
    resources :plants, only: [:create, :index] do
      resources :waterings, only: :create
    end
  end

  get '*destination', to: 'application#index'
end
