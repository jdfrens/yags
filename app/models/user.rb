class User < ActiveRecord::Base
  
  acts_as_login_model
  
  has_many :vials
  has_many :character_preferences
  has_one  :basic_preference 
  
end
