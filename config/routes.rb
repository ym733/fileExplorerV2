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

  # GET /stream
  get "stream", to: "main#stream"

  #==============================================================
  # Setup Controller
  #==============================================================

  # GET /setup
  get "/setup", to: "setup#index"

  # POST /setup/reset_user_password
  post "/setup/reset_user_password", to: "setup#reset_user_password"

  # POST /setup/get_MFA_QR
  post "/setup/get_MFA_QR", to: "setup#get_MFA_QR"

  # POST /setup/reset_mfa_token
  post "/setup/reset_mfa_token", to: "setup#reset_MFA_QR"

  # GET /access_denied
  get "/access_denied", to: "setup#access_denied"

  # GET /access_denied_admin
  get "/access_denied_admin", to: "setup#access_denied_admin"

  # POST /setup/verify_OTP
  post "/setup/verify_OTP", to: "setup#verify_OTP"

  # POST /setup/verify_password
  post "/setup/verify_password", to: "setup#verify_password"

  # if route is 404 then redirect to root
  match "*unmatched", to: redirect("/"), via: :all
end
