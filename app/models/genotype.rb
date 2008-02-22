class Genotype < ActiveRecord::Base
  belongs_to :fly
  
  def genotype_for?(character)
    gene_number == species.gene_number_of(character)
  end
  
  def species
    fly.species
  end
end
