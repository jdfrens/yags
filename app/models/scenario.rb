class Scenario < ActiveRecord::Base
  has_many :scenario_preferences, :dependent => :destroy
  
end
