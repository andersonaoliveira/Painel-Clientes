Rails.application.routes.draw do
  root to: 'home#index'
  get '/home/profile', to: 'home#profile'
  devise_for :admins, path: 'admins'
  devise_for :clients, path: 'clients'
  get '/clients/delete', to: 'clients#delete'
  post '/clients/delete', to: 'clients#delete'
  get '/clients/changeaccount', to: 'clients#changeaccount'
  post '/clients/changeaccount', to: 'clients#changeaccount'
  get 'search', to: 'admin/clients#search'

  resources :messages, only: %i[create]

  resources :orders, only: %I[index show] do
    post 'cancel', on: :member
    post 'pay', on: :member
  end

  resources :service_desks do
    post 'change_to_wait_approval_client', on: :member
    post 'close', on: :member
  end

  resources :credit_cards, only: %I[index new create] do
    post :down, :up, on: :member
  end

  resources :products, only: %I[index show] do
    post 'cancel', on: :member
    get 'buy', on: :member
    get 'choose_period', on: :member
    post 'create_order', on: :member
  end

  namespace :admin do
    resources :categories, only: %i[index new create edit update destroy]
    resources :clients, only: %I[index show]
    resources :products, only: %I[index show] do
      post 'cancel', on: :member
    end
    resources :orders, only: %I[index show] do
      post 'cancel', on: :member
    end
    resources :service_desks, only: %I[index show] do
      post 'close', on: :member
    end

    get 'my_service_desks', to: 'service_desks#my_service_desks'
    post 'assign_service_desk/:id', to: 'service_desks#assign_service_desk', as: :assign_service_desk
    resources :messages, only: %i[create]
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :orders, only: :show do
        patch 'payment', on: :collection
      end
      patch 'cancelation/:id', to: 'orders#cancelation', as: 'cancelation'
      get 'card_banners/:token', to: 'banners#show'
    end
  end
end
