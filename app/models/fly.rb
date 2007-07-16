class Fly < ActiveRecord::Base

  has_many :genotypes, :dependent => :destroy
  has_many :mom_of, :class_name => "Vial", :foreign_key => "mom_id"
  has_many :dad_of, :class_name => "Vial", :foreign_key => "dad_id"
  belongs_to :vial
  
  def phenotype(character)
    genotype = genotypes.select { |g| g.gene_number == species.gene_number_of(character) }.first
    species.phenotype_from character, genotype.mom_allele, genotype.dad_allele
  end
  
  def species
    Species.singleton
  end
  
  def male?
    phenotype(:sex) == :male
  end
  
  def female?
    phenotype(:sex) == :female
  end
  
  def used_as_parent?
    (self.mom_of != [] || self.dad_of != [])
  end
  
  def owner
    vial.owner
  end
  
  def mate_with(partner, bit_gen = RandomBitGenerator.new)
    if self.male? 
      raise ArgumentError, "mating two males" if partner.male?
      partner.mate_with(self, bit_gen)
    elsif partner.female?
      raise ArgumentError, "mating two females"
    else
      child = Fly.new
      mom_gamete = self.make_gamete(bit_gen)
      dad_gamete = partner.make_gamete(bit_gen)
      mom_gamete.zup(dad_gamete) do |mom, dad|
        child.genotypes << Genotype.create!(:gene_number => mom[1],
            :mom_allele => mom[0], 
            :dad_allele => dad[0])
      end
      child.save!
      child
    end
  end
  
  def make_gamete(bit_gen)
    side = 0
    gamete = []
    last_gene_number = nil
    species.order(genotypes).each do |genotype|
      if bit_gen.random_bit(species.distance_between(last_gene_number, genotype.gene_number)) == 1
        side = flip(side)
      end
      gamete << [side == 0 ? genotype.mom_allele : genotype.dad_allele, genotype.gene_number]
      last_gene_number = genotype.gene_number
    end
    gamete
  end
  
  private
  
  def flip(side)
    [1, 0][side]
  end
  
end
