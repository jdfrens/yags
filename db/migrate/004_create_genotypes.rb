class CreateGenotypes < ActiveRecord::Migration
  def self.up
    create_table :genotypes do |t|
      t.column :fly_id, :integer
      t.column :position, :float
      t.column :mom_allele, :integer
      t.column :dad_allele, :integer
    end
    Fly.find(:all).each_with_index do |fly, i|
      fly.genotypes << Genotype.new(:position => 0.5, :mom_allele => fly.locus_mom, :dad_allele => fly.locus_dad)
      fly.genotypes << Genotype.new(:position => 0.0, :mom_allele => 1, :dad_allele => i % 2)
      fly.save!
    end
    
  end
  
  def self.down
    drop_table :genotypes
  end
end
