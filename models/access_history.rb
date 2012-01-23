class AccessHistory < ActiveRecord::Base
  belongs_to :device, :counter_cache => :access_count
end
