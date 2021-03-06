class AddMultipleGenesToFlies < ActiveRecord::Migration
  def self.up
    bit_generator = RandomBitGenerator.new
    Fly.find(:all).each do |fly|
      fly.genotypes << Genotype.new(:position => 1.0, 
          :mom_allele => bit_generator.random_bit, :dad_allele => bit_generator.random_bit)
      fly.genotypes << Genotype.new(:position => 1.2, 
          :mom_allele => bit_generator.random_bit, :dad_allele => bit_generator.random_bit)
      fly.save!
    end
  end

  def self.down
    Fly.find(:all).each do |fly|
      fly.genotypes.select do |g|
        g.position == 1.0 or g.position == 1.2
      end.each { |g| g.destroy }
      fly.save!
    end
  end
end
