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
    @gene_numbers = { :gender => 137, :eye_color => 52, :wings => 163, :legs => 7 }
    
    # or should this be a hash from characters to positions still?
    @positions = { 137 => 0.0, 52 => 0.5, 163 => 1.0, 7 => 1.2 }
  end
  
  def phenotypes(character)
    @phenotypes[character]
  end
  
  def gene_number_of(character)
    @gene_numbers[character]
  end
  
  def position_of(gene_number)
    @positions[gene_number]
  end
  
  def phenotype_from(character, mom_allele, dad_allele)
    @phenotypes[character][mom_allele + dad_allele]
    # replace this with a look-up table
  end
  
  def order(genotypes)
    genotypes.sort { |a, b| position_of(a.gene_number) <=> position_of(b.gene_number) }
  end
  
end