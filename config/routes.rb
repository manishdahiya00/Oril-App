Rails.application.routes.draw do
  mount API::Base => "/"

  root "main#index"

  get "/invite/:id" => "main#invite"

  get "/admin/dashboard" => "admin/dashboard#index"
  get "/admin" => "admin/login#new"
  post "/admin" => "admin/login#login"
  delete "/admin/logout" => "admin/login#logout"

  namespace :admin do
    resources :users
    resources :reels
    resources :musics
    resources :reported_reels
    resources :payoutss
    resources :verification_requests
    resources :delete_requests
    resources :orders
    put "verifyRequest/:id", to: "verification_requests#verifyUser", as: "verify_request"
    put "reels/:id/approveReel", to: "reels#approveReel", as: "approve_reel"
    put "reported_reels/:id/approveReel", to: "reported_reels#approveReel", as: "approve_reported_reel"
    post "payouts/:id", to: "users#payout", as: "payout"
  end
end
