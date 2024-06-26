Rails.application.routes.draw do
  mount API::Base => '/'

  root "main#index"

  get "/admin/dashboard" => "admin/dashboard#index"
  get "/admin" => "admin/login#new"
  post "/admin" => "admin/login#login"
  delete "/admin/logout" => "admin/login#logout"

  namespace :admin do
    resources :users
    resources :reels
    resources :musics
    resources :reported_reels
    put 'reels/:id/approveReel', to: 'reels#approveReel', as: 'approve_reel'
    put 'reported_reels/:id/approveReel', to: 'reported_reels#approveReel', as: 'approve_reported_reel'
  end

end
