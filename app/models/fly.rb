class Fly < ActiveRecord::Base

  def phenotype
    pheno_list = [:recessive, :dominant, :dominant]
    pheno_list[locus_mom + locus_dad]
  end
 
end
