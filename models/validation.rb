#encoding: utf-8
class Validation < ActiveRecord::Base
  belongs_to :device
  scope :active, where(:expired => false)

  def self.one_valid
    where(:expired => false).first(:order => "RANDOM()")
  end

  def expire
    self.expired = true
    if self.device && self.device.user
      $logger.info "Sending message to #{self.device.user.phone}"
      sms = Clickatell::API.authenticate(3354213,'siribrazil','raphael1289')
      sms.send_message(self.device.user.phone, 'O código do seu iPhone 4S expirou, por favor envie ele novamente ligando a VPN e chamando o Siri. SiriBrazil');
    end    
  end
end