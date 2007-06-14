class User < ActiveRecord::Base
  
  acts_as_login_model
  
  has_many :vials
  
end
