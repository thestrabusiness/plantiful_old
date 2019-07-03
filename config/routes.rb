Rails.application.routes.draw do
  namespace :api do
    resources :plants, only: :index
  end
  resources :plants, only: [:index, :new, :create, :show] do
    resources :waterings, only: [:create]
  end
  
  root 'application#index'
end
