class Fly < ActiveRecord::Base
  has_many :genotypes, :dependent => :destroy
  
  def phenotype(character)
    genotype = genotypes.select { |g| g.gene_number == species.gene_number_of(character) }.first
    species.phenotype_from character, genotype.mom_allele, genotype.dad_allele
  end

  def vial
    Vial.find(vial_id)
  end
  
  def species
    Species.singleton
  end
  
  def male?
    phenotype(:gender) == :male
  end
  
  def female?
    phenotype(:gender) == :female
  end
  
  def mate_with(partner, bit_gen = RandomBitGenerator.new)
    if male? 
      raise ArgumentError, "mating two males" if partner.male?
      partner.mate_with(self, bit_gen)
    elsif partner.female?
      raise ArgumentError, "mating two females"
    else
      child = Fly.create!   # is this correct?  use create! or new ?
      genotypes.zip(partner.genotypes) do |pair|
        child.genotypes << Genotype.create!(:gene_number => pair[0].gene_number, 
            :mom_allele => bit_gen.random_bit == 0 ? pair[0].mom_allele : pair[0].dad_allele,
            :dad_allele => bit_gen.random_bit == 0 ? pair[1].mom_allele : pair[1].dad_allele)
      end
      child.save!
      child
    end
  end
  
end
