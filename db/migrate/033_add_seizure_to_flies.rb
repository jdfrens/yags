class AddSeizureToFlies < ActiveRecord::Migration
  def self.up
    bit_generator = RandomBitGenerator.new
    Fly.find(:all).each do |fly|
      fly.genotypes << Genotype.new(:gene_number => 19, 
          :mom_allele => bit_generator.random_bit, :dad_allele => bit_generator.random_bit)
      fly.save!
    end
  end

  def self.down
    Genotype.find(:all).each do |g|
      g.destroy if g.gene_number == 19
      g.save!
    end
  end
end
