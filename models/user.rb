class User < ActiveRecord::Base
  has_one :device
end