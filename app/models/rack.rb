class Rack < ActiveRecord::Base

  has_many :vials
  belongs_to :owner, :class_name => "User", :foreign_key => "user_id"
  belongs_to :scenario
  
  validates_presence_of :label
  validates_presence_of :user_id
  validates_presence_of :scenario_id
  
end
