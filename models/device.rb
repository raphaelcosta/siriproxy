class Device < ActiveRecord::Base
  belongs_to :user
  has_many :validations
  has_many :access_histories
  validates_uniqueness_of :speechid,:assistantid,:token

  def generate_token
    generated_token = ""
    loop do
      generated_token = SecureRandom.base64(15).tr('+/=lIO0', 'pqrsxyz')
      break unless Device.where(:token =>  generated_token).first
    end

    puts generated_token

    self.token = generated_token
  end

  def confirmed?
    !!confirmed_at
  end

  def confirm_by_token(confirmation_token)
    confirmable = find_or_initialize_with_error_by(:token, confirmation_token)
    confirmable.confirm! if confirmable.persisted?
    confirmable
  end

   def confirm!
    self.token = nil
    self.confirmed_at = Time.now.utc
    self.save(:validate => false)
  end
end
