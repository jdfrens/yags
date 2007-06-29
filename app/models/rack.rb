class Rack < ActiveRecord::Base

  has_many :vials
  belongs_to :user
  
  validates_presence_of :label
  
end
