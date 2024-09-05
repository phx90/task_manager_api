Rails.application.routes.draw do
  get 'users/index'
  get 'users/show'
  get 'users/update'
  get 'users/destroy'
  # Rotas para autenticação (signup e login)
  post 'signup', to: 'authentication#signup'
  post 'login', to: 'authentication#login'

  # Rotas para tarefas (não aninhadas)
  resources :tasks, only: [:index, :create, :show, :update, :destroy]

  resources :users, only: [:index, :create, :show, :update, :destroy]
  # Outras rotas, como projetos, se necessário
  resources :projects
end

