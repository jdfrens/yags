class Species
  
  attr_reader :characters
  
  def self.singleton
    Species.new
  end
  
  def initialize
    @characters = [:gender, :eye_color, :wings, :legs]
    @phenotypes = { :gender => [:not_possible, :male, :female], 
                    :eye_color => [:white, :red, :red], 
                    :wings => [:curly, :straight, :straight], 
                    :legs => [:smooth, :hairy, :hairy] }
    @positions = { :gender => 0.0, :eye_color => 0.5, :wings => 1.0, :legs => 1.2 }
  end
  
  def phenotypes(character)
    @phenotypes[character]
  end
  
  def position_of(character)
    @positions[character]
  end
  
  def phenotype_from(character, mom_allele, dad_allele)
    @phenotypes[character][mom_allele + dad_allele]
    # replace this with a look-up table
  end
  
end