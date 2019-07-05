Rails.application.routes.draw do
  root 'application#index'

  namespace :api do
    resources :plants, only: :index
  end

#  resources :plants, only: [:new, :create, :show] do
#    resources :waterings, only: [:create]
#  end

  get '*destination', to: 'application#index'
end
