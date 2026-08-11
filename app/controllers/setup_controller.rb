class SetupController < ApplicationController
  def index
    if (not session[:admin_last_seen_at]) || session[:admin_last_seen_at] < 10.minutes.ago
      redirect_to access_denied_admin_path
    end
  end

  def reset_user_password
    if params[:password].present? && params[:password] == params[:password_confirmation]
      unless Password.where(LoginType: "user").last.nil?
        Password.where(LoginType: "user").last.update_column(:isActive, false)
      end
      Password.create({LoginType: "user", isActive: true, password: params[:password], password_confirmation: params[:password_confirmation]})
      redirect_to access_denied_path, notice: "Password changed successfully"
    else
      redirect_to access_denied_path, notice: "Unable to change password"
    end
  end

  def get_MFA_QR
    
    if MfaToken.last.nil?
      MfaToken.create_new_otp
    end

    @qr_svg = RQRCode::QRCode.new(MfaToken.otp_provisioning_uri).as_svg(module_size: 4)
    render partial: "/setup/get_mfa_qr", status: :ok
  end

  def reset_MFA_QR
    
    if MfaToken.last.nil?
      MfaToken.create_new_otp
    else
      MfaToken.reset_otp
    end

    @qr_svg = RQRCode::QRCode.new(MfaToken.otp_provisioning_uri).as_svg(module_size: 4)
    render partial: "/setup/get_mfa_qr", status: :ok
  end

  def access_denied
    @password_type = "user"

    # Check if any passwords exists and reflect that in the view asking users to setup a password
    @user_password_exists = Password.where(LoginType: "user").last.present?
    # Check if any OTPs exists and reflect that in the view asking users to setup an OTP
    @user_OTP_exists = MfaToken.where(isActive: true).last.present?
    
  end

  def access_denied_admin
    @password_type = "admin"

    # Check if any passwords exists and reflect that in the view asking users to setup a password
    @admin_password_exists = Password.where(LoginType: "admin").last.present?
    ##################################################################################
    #
    #       To create an admin password, the following line needs to be
    #             Entered into the rails console in the terminal:
    #
    #     Password.create({LoginType: "admin", isActive: true, password: "", password_confirmation: ""})
    # 
    #
    ##################################################################################
    
    render "/setup/access_denied", status: :ok
  end

  def verify_OTP
    code = params[:otp]

    if MfaToken.verify_otp(code) then
      cookie = session[:session_id]
      ip_address = request.remote_ip

      CustomSession.create_new_session(cookie, ip_address)

      session[:last_seen_at] = Time.current
      redirect_to root_path
    else
      redirect_to access_denied_path, notice: "Unable to grant access"
    end
  end

  def verify_password
    password_type = params[:password_type]
    password = params[:password]

    if password_type == "user" then
      if Password.check_user_password(password) then
        cookie = session[:session_id]
        ip_address = request.remote_ip

        CustomSession.create_new_session(cookie, ip_address)

        session[:last_seen_at] = Time.current
        redirect_to root_path
      else
        redirect_to access_denied_path, notice: "Unable to grant access"
      end
    else
      if Password.check_admin_password(password) then
        session[:admin_last_seen_at] = Time.current
        redirect_to setup_path
      else
        redirect_to access_denied_admin_path, notice: "Unable to grant access"
      end
    end

  end
  
end
