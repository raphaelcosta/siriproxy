class Validation < ActiveRecord::Base
  belongs_to :device
  scope :active, where(:expired => false)

  def self.one_valid
    where(:expired => false).first(:order => "RANDOM()")
  end
end