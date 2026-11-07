Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  root "home#index"
  get "home/index"
  resources :rooms
  post "rooms/auth", to: "rooms#auth"
  delete "rooms/:id/stream", to: "rooms#toggle_stream", as: :toggle_stream
  post "locale/:locale", to: "locales#update", as: :set_locale
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development? || Rails.env.test?

  get "up" => "rails/health#show", as: :rails_health_check
end
