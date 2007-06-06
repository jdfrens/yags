class Vial < ActiveRecord::Base
  has_many :flies, :dependent => :destroy
  
  include CartesianProduct
  
  validates_presence_of :label
  
  def self.collect_from_field(vial_params, number, bit_generator = RandomBitGenerator.new, allele_frequences = {})
    allele_frequences.default = 0.5
    vial = Vial.create!(vial_params)
    species = vial.species
    number.times do |i|
       new_fly = Fly.create!
       species.characters.each do |character|
         if character == :gender # could this be handled better?
           new_fly.genotypes << Genotype.create!(:fly_id => new_fly.id, :position => species.position_of(:gender), 
               :mom_allele => 1, :dad_allele => bit_generator.random_bit(allele_frequences[:gender]))
         else
           new_fly.genotypes << Genotype.create!(:fly_id => new_fly.id, :position => species.position_of(character), 
               :mom_allele => bit_generator.random_bit(allele_frequences[character]), :dad_allele => bit_generator.random_bit(allele_frequences[character]))
         end
       end
       vial.flies << new_fly
       vial.save!
    end
    vial
  end
  
  def self.make_babies_and_vial(vial_params, number, bit_generator = RandomBitGenerator.new)
    vial = Vial.create!(vial_params)
    species = vial.species
    mom = Fly.find vial.mom_id
    dad = Fly.find vial.dad_id
    number.times do |i|
      vial.flies << mom.mate_with(dad, bit_generator)
      vial.save!
    end
    vial
  end
  
  def species
    Species.singleton
  end
  
  def combinations_of_phenotypes(characters = species.characters)
    # characters = [*characters]
    cartesian_product(characters.collect { |c| species.phenotypes(c).uniq } )
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
  
end
