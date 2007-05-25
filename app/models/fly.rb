class Fly < ActiveRecord::Base

  def phenotype
    pheno_list = [:recessive, :het, :homdom]
    pheno_list[locus_mom + locus_dad]
  end
 
end
