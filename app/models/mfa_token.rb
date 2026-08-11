class MfaToken < ApplicationRecord
  def self.create_new_otp
    create({token: ROTP::Base32.random, isActive: true})
  end

  def self.reset_otp
    where(isActive: true).last.update_column(:isActive, false)
    create({token: ROTP::Base32.random, isActive: true})
  end

  def self.otp_provisioning_uri
    lastToken = where(isActive: true).last.token

    ROTP::TOTP.new(lastToken, issuer: "FileExplorerV2").provisioning_uri("User OTP #{count()}")
  end

  def self.verify_otp(code)
    lastToken = where(isActive: true).last.token

    totp = ROTP::TOTP.new(lastToken)
    totp.verify(code, drift_behind: 15, drift_ahead: 15)
  end
end
