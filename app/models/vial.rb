class Vial < ActiveRecord::Base

  has_many :flies, :dependent => :destroy
  belongs_to :user
  
  include CartesianProduct
  
  validates_presence_of :label
  
  def self.collect_from_field(vial_params, number, bit_generator = RandomBitGenerator.new, allele_frequencies = {})
    vial = Vial.new(vial_params)
    allele_frequencies[:gender] = 0.5 unless allele_frequencies[:gender]
    # or should we vary the gender ratios along with everything else?
    vial.species.characters.each do |character|
      allele_frequencies[character] = 0.13 + (rand 37) / 100.0 unless allele_frequencies[character]
    end
    if vial.save
      vial.fill_from_field(number, bit_generator, allele_frequencies)
    end
    vial
  end
  
  def self.make_babies_and_vial(vial_params, number, bit_generator = RandomBitGenerator.new)
    vial = Vial.new(vial_params)
    species = vial.species
    mom = Fly.find vial.mom_id
    dad = Fly.find vial.dad_id
    if vial.save
      number.times do |i|
        vial.flies << mom.mate_with(dad, bit_generator)
      end
    end
    vial
  end
  
  def species
    Species.singleton
  end
  
  def combinations_of_phenotypes(characters = species.characters)
    cartesian_product( characters.collect do |character| 
      phenotypes = species.phenotypes(character)
    end )
  end
  
  def number_of_flies (characters, phenotypes)
    flies_of_type(characters, phenotypes).size
  end
  
  def first_of_type (characters, phenotypes)
    flies_of_type(characters, phenotypes).first
  end
  
  def flies_of_type (characters, phenotypes)
    characters, phenotypes = [*characters], [*phenotypes]
    selection = flies
    characters.each_with_index do |character, i|
      selection = selection.select do |fly|
        fly.phenotype(character) == phenotypes[i]
      end
    end
    selection
  end

  def fill_from_field(number, bit_generator, allele_frequencies)
    number.times do |i|
       new_fly = Fly.create!
       species.characters.each do |character|
         if character == :gender # could this be handled better?
           new_fly.genotypes << Genotype.create!(:fly_id => new_fly.id, :gene_number => species.gene_number_of(:gender), 
               :mom_allele => 1, :dad_allele => bit_generator.random_bit(allele_frequencies[:gender]))
         else
           new_fly.genotypes << Genotype.create!(:fly_id => new_fly.id, :gene_number => species.gene_number_of(character), 
               :mom_allele => bit_generator.random_bit(allele_frequencies[character]), 
               :dad_allele => bit_generator.random_bit(allele_frequencies[character]))
         end
       end
       flies << new_fly
    end
    self
  end
  
end
