Rails.application.routes.draw do
  get 'home/index'

  root 'home#index'
  post '/process_form', to: 'home#process_form'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get '/download_txt/:uuid', to: 'home#download_txt', as: 'download'
  get '/download_binary/:uuid', to: 'home#download_binary', as: 'downloadbin'
  get '/download_file/:uuid/:ext', to: 'home#download_file', as: 'downloadfile'
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
