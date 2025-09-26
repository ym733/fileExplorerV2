# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  # GET /
  root to: "main#index"

  # GET /file
  get '/file', to: "main#file"
end
