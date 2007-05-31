class Fly < ActiveRecord::Base
  has_many :genotypes, :dependent => :delete_all
    
  EYE_COLOR_LOOKUP = [:white, :red, :red]
  GENDER_LOOKUP = [:not_possible, :male, :female]
  
  def phenotype(character)
    case character
    when :eye_color 
      genotype = genotypes.find(:first, :conditions => "position = 0.5")
      EYE_COLOR_LOOKUP[genotype.mom_allele + genotype.dad_allele]
    when :gender 
      genotype = genotypes.find(:first, :conditions => "position = 0.0")
      GENDER_LOOKUP[genotype.mom_allele + genotype.dad_allele]
    end
  end
  
  def vial
    Vial.find(vial_id)
  end
  
end
