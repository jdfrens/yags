class Vial < ActiveRecord::Base
  has_many :flies
  
  validates_presence_of :label
  
  def number_of_flies (character, phenotype)
    flies.select do |fly|
      fly.phenotype(character) == phenotype
    end.size
  end
    
end
