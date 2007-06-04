class Fly < ActiveRecord::Base
  has_many :genotypes, :dependent => :destroy
    
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
  
  def species
    Species.singleton
  end
  
  def mate_with(partner, bit_generator = RandomBitGenerator.new)
    if self.phenotype(:gender) == :male 
      raise ArgumentError, "mating two males" if partner.phenotype(:gender) == :male
      partner.mate_with(self, bit_generator)
    elsif partner.phenotype(:gender) == :female
      raise ArgumentError, "mating two females"
    else
      child = Fly.create!   #is this correct?  use create! or new ?
      last_position = genotypes[0].position
      genotypes.zip(partner.genotypes) do |pair|
        #distance = last_position - pair[0].position
        m = bit_generator.random_bit == 0 ? pair[0].mom_allele : pair[0].dad_allele
        d = bit_generator.random_bit == 0 ? pair[1].mom_allele : pair[1].dad_allele
        last_position = pair[0].position
        child.genotypes << Genotype.create!(:position => last_position, :mom_allele => m, :dad_allele => d)
      end
      child.save!
      child
    end
  end
  
end
