class Vial < ActiveRecord::Base
  has_many :flies
  
  validates_presence_of :label
  
  def number_of_flies (phenotype)
    flies.select do |fly|
      fly.phenotype == phenotype
    end.size
  end
    
end
