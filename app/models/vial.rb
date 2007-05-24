class Vial < ActiveRecord::Base
  has_many :flies

  validates_presence_of :label
  
end
