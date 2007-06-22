class AddAntennaToFlies < ActiveRecord::Migration
  def self.up
  bit_generator = RandomBitGenerator.new
    Fly.find(:all).each do |fly|
      fly.genotypes << Genotype.new(:gene_number => 144, 
          :mom_allele => bit_generator.random_bit, :dad_allele => bit_generator.random_bit)
      fly.save!
    end
  end

  def self.down
    Fly.find(:all).each do |fly|
      fly.genotypes.select do |g|
        g.gene_number == 144
      end.each { |g| g.destroy }
      fly.save!
    end
  end
end
