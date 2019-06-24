Rails.application.routes.draw do
  resources :plants, only: [:index, :new, :create] do
    resources :waterings, only: [:create]
  end
  root "plants#index"
end
