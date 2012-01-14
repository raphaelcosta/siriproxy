class User < ActiveRecord::Base
  has_many :validations
end