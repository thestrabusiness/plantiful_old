Rails.application.routes.draw do
  root 'application#index'

  namespace :api do
    resources :plants, only: [:create, :index, :show, :destroy] do
      post :avatar, on: :member
      resources :check_ins, only: :create
    end
    resources :users, only: [:create]
    resource :current_user, only: :show
    resources :sessions, only: :create
    delete "/sign_out" => "sessions#destroy", as: "sign_out"
  end

  get '*destination', to: 'application#index', constraints: lambda { |req|
    req.path.exclude? '/rails/active_storage'
  }
end
