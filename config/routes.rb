Rails.application.routes.draw do

  resources :advertisements
  root :to => 'advertisements#index'
  
end
