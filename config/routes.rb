# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  # GET /
  root to: "main#index"

  # GET /file
  get "/file", to: "main#file"

  # GET /refresh_file
  get "/refresh_file", to: "main#refresh_file"

  # GET /folder
  get "/folder", to: "main#folder"

  # POST /save
  post "/save", to: "main#save"

  # GET /back
  get "/back", to: "main#back"

  # POST /new_file
  post "/new_file", to: "main#new_file"

  # POST /upload
  post "/upload", to: "main#upload"

  # DELETE /delete_file
  delete "/delete_file", to: "main#delete_file"

  # GET /download_file
  get "/download_file", to: "main#download_file"

  # GET /children
  get "/children", to: "main#children"
end
