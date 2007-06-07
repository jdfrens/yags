class AddGeneNumberToGenotypes < ActiveRecord::Migration
  def self.up
    add_column :genotypes, :gene_number, :integer
    Genotype.find(:all).each do |genotype|
      case genotype.position
      when 0.0
        genotype.gene_number = 137
      when 0.5
        genotype.gene_number = 52
      when 1.0
        genotype.gene_number = 163
      when 1.2
        genotype.gene_number = 7
      end
      genotype.save!
    end
  end

  def self.down
    remove_column :genotypes, :gene_number
  end
end
