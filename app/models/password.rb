# type:string
# password_digest:string
#
# password:string virtual
# password_confirmation:string virtual

class Password < ApplicationRecord
  has_secure_password

  def self.check_user_password(password)
    instance = where(LoginType: "user").last

    return instance.present? && instance.authenticate(password)
  end

  def self.check_admin_password(password)
    instance = where(LoginType: "admin").last

    return instance.present? && instance.authenticate(password)
  end
end
