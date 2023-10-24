Rails.application.routes.draw do
  get 'greetings/random', to: 'greetings#random'
  resources :greetings
  resource :users, only: [:create]
  post '/login', to: 'users#login'
  get 'auto_login', to: 'users#auto_login'
end