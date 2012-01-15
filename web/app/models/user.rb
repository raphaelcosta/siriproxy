class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,:speech_id,:assistant_id,:initial_token,:seeder

  validates_uniqueness_of :speech_id,:assistant_id,:initial_token

  has_many :validations

  def name
    self.email
  end

  def generate_initial_token

    loop do
      token = SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz')
      break token unless self.find_first({ :initial_token => token })
    end

    self.initial_token = token
  end

  def confirmed?
    !!confirmed_at
  end

  def confirm_by_token(confirmation_token)
    confirmable = find_or_initialize_with_error_by(:confirmation_token, confirmation_token)
    confirmable.confirm! if confirmable.persisted?
    confirmable
  end

   def confirm!
    self.confirmation_token = nil
    self.confirmed_at = Time.now.utc
    self.save(:validate => false)
  end

end
