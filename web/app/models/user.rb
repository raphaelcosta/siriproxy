#encoding: utf-8
class User < ActiveRecord::Base
  default_scope :order => 'name ASC'
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,:seeder,:name,:phone
  has_many :devices

  def send_sms
    sms = Clickatell::API.authenticate(3354213,'siribrazil','raphael1289')
    sms.send_message(self.phone, "Não recebemos o código do seu 4S, favor fazer o procedimento de envio.Obrigado! SiriBrazil")
  end

end
