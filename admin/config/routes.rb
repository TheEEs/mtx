Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[new create]
  get "sign_up", to: "registrations#new"
  resources :confirmations, param: :token, only: %i[new create show]
  get "confirmations/:token", to: "confirmations#show", as: :confirm_email

  root "home#index"
  get "home/index"
  resources :rooms
  post "rooms/auth", to: "rooms#auth"
  delete "rooms/:id/stream", to: "rooms#toggle_stream", as: :toggle_stream
  post "locale/:locale", to: "locales#update", as: :set_locale
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development? || Rails.env.test?

  get "up" => "rails/health#show", as: :rails_health_check
end
