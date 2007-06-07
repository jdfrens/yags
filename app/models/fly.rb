class Fly < ActiveRecord::Base
  has_many :genotypes, :dependent => :destroy
  
  def phenotype(character)
    genotype = genotypes.select { |g| g.gene_number == species.gene_number_of(character) }.first
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
      genotypes.zip(partner.genotypes) do |pair|
        m = bit_generator.random_bit == 0 ? pair[0].mom_allele : pair[0].dad_allele
        d = bit_generator.random_bit == 0 ? pair[1].mom_allele : pair[1].dad_allele
        current_gene_number = pair[0].gene_number
        child.genotypes << Genotype.create!(:gene_number => current_gene_number, :mom_allele => m, :dad_allele => d)
      end
      child.save!
      child
    end
  end
  
end
