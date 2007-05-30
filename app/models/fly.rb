class Fly < ActiveRecord::Base
  has_many :genotypes, :dependent => :delete_all

  # 
  # Creates an array with the phenotypes.
  # White = recessive
  # Red = dominant
  def phenotype
    pheno_list = [:white, :red, :red]
    pheno_list[locus_mom + locus_dad]
  end
 
end
