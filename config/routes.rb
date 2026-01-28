# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  # GET /
  root to: "main#index"

  # GET /file
  get "/file", to: "main#file"

  #GET /refresh_file

  get "/refresh_file", to: "main#refresh_file"

  # GET /folder
  get "/folder", to: "main#folder"

  # POST /save
  post "/save", to: "main#save"

  # GET /back
  get "/back", to: "main#back"

  # POST /new_item
  post "/new_item", to: "main#new_item"

  # POST /upload
  post "/upload", to: "main#upload"
end
