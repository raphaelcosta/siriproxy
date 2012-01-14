class Validation < ActiveRecord::Base
  belongs_to :user
  scope :active, where(:expired => false)

  def self.one_valid
    where(:expired => false).first(:order => "RANDOM()")
  end
end