class GiveMalesRecessiveDadAllelesForAntenna < ActiveRecord::Migration
  def self.up
    Fly.find(:all).each do |fly|
      if fly.male?
        genotype = fly.genotypes.select { |g| g.gene_number == 144 }.first
        genotype.dad_allele = 0
        genotype.save!
      end
    end
  end

  def self.down
    # this isn't important
  end
end
