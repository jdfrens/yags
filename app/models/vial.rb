class Vial < ActiveRecord::Base
  has_many :flies
  
  validates_presence_of :label
  
  # The following methods return the size
  # of the flies array with the specified phenotype
  #
  def number_of_recessive_flies
    flies.select do |fly|
      fly.phenotype == :recessive
    end.size
  end
  
  def number_of_heterozygote_flies
    flies.select do |fly|
      fly.phenotype == :het
    end.size
  end
  
  def number_of_homozygote_flies
    flies.select do |fly|
      fly.phenotype == :homdom
    end.size
  end
    
end
