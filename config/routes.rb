Rails.application.routes.draw do
  resources :plants, only: [:index, :new, :create, :show] do
    resources :waterings, only: [:create]
  end
  root 'application#index'
end
