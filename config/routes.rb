Rails.application.routes.draw do
  post 'signup', to: 'authentication#signup'
  post 'login', to: 'authentication#login'

  resources :projects do
    resources :tasks
  end
end
