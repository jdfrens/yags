class Rack < ActiveRecord::Base

  has_many :vials # should be dependent => destroy  ???
  belongs_to :user
  
  validates_presence_of :label
  
end
