Rails.application.routes.draw do
  mount API::Base => '/'

  root "main#index"
end
