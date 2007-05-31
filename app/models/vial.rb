class Vial < ActiveRecord::Base
  has_many :flies
  
  validates_presence_of :label
  
  def number_of_flies (character, phenotype)
    flies_of_type(character, phenotype).size
  end
  
  def first_of_type (character, phenotype)
    flies_of_type(character, phenotype).first
  end
  
  #
  # Helpers
  #
  private
  
  def flies_of_type (character, phenotype)
    character, phenotype = [*character], [*phenotype]
    selection = flies
    character.size.times do |i|
      selection = selection.select do |fly|
        fly.phenotype(character[i]) == phenotype[i]
      end
    end
    selection
  end
  
end
