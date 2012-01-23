class ValidationHistory < ActiveRecord::Base
  belongs_to :validation
  belongs_to :device
end
