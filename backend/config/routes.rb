Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get    "health", to: "health#show"

      # Autenticação
      post   "signup", to: "registrations#create"
      post   "login",  to: "sessions#create"
      delete "logout", to: "sessions#destroy"
      get    "me",     to: "users#me"
      get    "profile", to: "profiles#show"

      # Domínio
      get "dashboard", to: "dashboard#show"

      resources :employees do
        member { get :history }
      end

      resources :departments

      resources :notifications, only: %i[index show destroy] do
        member     { patch :read }
        collection { patch :read_all }
      end

      resources :roles, only: %i[index show]
      resources :permissions, only: :index
    end
  end

  # Defines the root path route ("/")
  root "home#index"
end
