class Species
  
  attr_reader :characters
  
  def self.singleton
    Species.new
  end
  
  def initialize
    @characters = [:sex, :eye_color, :wings, :legs, :antenna]
    @phenotypes = { :sex => [:male, :female], 
                    :eye_color => [:white, :red], 
                    :wings => [:curly, :straight], 
                    :legs => [:smooth, :hairy],
                    :antenna => [:short, :long] }
    @alternate_phenotypes = { :eye_color => [:orange, :beige, :turquoise, :blue, :green, :maroon] }
    @alternate_phenotypes.default = [] # is this the defaul we want?
    @phenotype_lookup = { :sex => {[1,1] => :female, [0,1] => :male, [0,0] => :not_possible },
                          :eye_color => {[1,1] => :red, [0,1] => :red, [0,0] => :white }, 
                          :wings => {[1,1] => :straight, [0,1] => :straight, [0,0] => :curly }, 
                          :legs => {[1,1] => :hairy, [0,1] => :hairy, [0,0] => :smooth },
                          :antenna => {[1,1] => :long, [0,1] => :long, [0,0] => :short } }
    @gene_numbers = { :sex => 137, :eye_color => 52, :wings => 163, :legs => 7, :antenna => 144}
    @positions = { 137 => 0.0, 52 => 0.5, 163 => 1.0, 7 => 1.2, 144 => 0.0 }
  end
  
  def phenotypes(character)
    @phenotypes[character]
  end
  
  def alternate_phenotypes(character)
    @alternate_phenotypes[character]
  end
  
  def random_alternate_for(character)
    # to make or not to make
  end
  
  def gene_number_of(character)
    @gene_numbers[character]
  end
  
  def is_sex_linked?(character)
    character != :sex and position_of(gene_number_of(character)) == 0.0
  end
  
  def position_of(gene_number)
    @positions[gene_number]
  end
  
  def phenotype_from(character, mom_allele, dad_allele)
    @phenotype_lookup[character][[mom_allele, dad_allele].sort]
  end
  
  def order(genotypes)
    genotypes.sort do |a, b| 
      if (comparison_value = position_of(a.gene_number) <=> position_of(b.gene_number)) != 0
        comparison_value
      else
        a.gene_number <=> b.gene_number
        # this gives sex linked genes a definite order
      end
    end
  end
  
  def distance_between(gene_number1, gene_number2)
    if gene_number1.nil? or 
        (distance = position_of(gene_number2) - position_of(gene_number1)) > 0.5
      0.5
    else
      distance
    end
  end
  
end