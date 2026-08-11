class CustomSession < ApplicationRecord

  def self.create_new_session(cookie, address)
    create({cookie: cookie, IP: address, login_count: where(cookie: cookie).count + 1, expire_time: Time.current + 2.hours})
  end 
end
