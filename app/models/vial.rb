class Vial < ActiveRecord::Base
  has_many :flies, :dependent => :destroy
  
  include CartesianProduct
  
  validates_presence_of :label
  
  def species
    Species.singleton
  end
  
  def combinations_of_phenotypes(characters = species.characters)
    # characters = [*characters]
    cartesian_product(characters.collect { |c| species.phenotypes(c).uniq } )
  end
  
  def number_of_flies (characters, phenotypes)
    flies_of_type(characters, phenotypes).size
  end
  
  def first_of_type (characters, phenotypes)
    flies_of_type(characters, phenotypes).first
  end
  
  def flies_of_type (characters, phenotypes)
    characters, phenotypes = [*characters], [*phenotypes]
    selection = flies
    characters.each_with_index do |character, i|
      selection = selection.select do |fly|
        fly.phenotype(character) == phenotypes[i]
      end
    end
    selection
  end
  
end
