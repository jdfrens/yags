class Rack < ActiveRecord::Base

  has_many :vials
  
  validates_presence_of :label
  
end
