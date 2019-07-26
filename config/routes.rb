Rails.application.routes.draw do
  root 'application#index'

  namespace :api do
    resources :plants, only: [:create, :index] do
      resources :waterings, only: :create
    end
    resources :users, only: :create
    resources :sessions, only: :create
    delete "/sign_out" => "sessions#destroy", as: "sign_out"
  end

  get '*destination', to: 'application#index'
end
