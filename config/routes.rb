Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :sessions, only: %i[new]
  resources :streams,  only: %i[index show]
  root 'welcome#index'
end
