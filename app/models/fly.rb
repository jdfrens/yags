class Fly < ActiveRecord::Base
  has_many :genotypes, :dependent => :destroy
  
  def phenotype(character)
    genotype = genotypes.select { |g| g.position == species.position_of(character) }.first
    species.phenotype_from character, genotype.mom_allele, genotype.dad_allele
  end
  
  # 
  def phenotypes
    species.phenotypes
  end
  #
  
  def vial
    Vial.find(vial_id)
  end
  
  def species
    Species.singleton
  end
  
  def male?
    phenotype(:gender) == :male
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
