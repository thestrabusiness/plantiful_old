Rails.application.routes.draw do
  resources :plants, only: [:index, :new, :create]
  root "plants#index"
end
