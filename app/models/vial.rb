class Vial < ActiveRecord::Base

  has_many :flies, :dependent => :destroy
  belongs_to :mom, :class_name => 'Fly', :foreign_key => 'mom_id'
  belongs_to :dad, :class_name => 'Fly', :foreign_key => 'dad_id'
  has_one :solution
  belongs_to :rack
  
  include CartesianProduct
  
  validates_presence_of :label
  validates_presence_of :rack_id  # TODO: test this
  validates_numericality_of :number_of_requested_flies, :only_integer => true,
      :on => :create
  validates_inclusion_of :number_of_requested_flies, :in => 0..255,
      :message => "should be between 0 and 255",
      :on => :create
  validates_presence_of :mom_id, :if => Proc.new { |vial| vial.offspring_vial? }
  validates_presence_of :dad_id, :if => Proc.new { |vial| vial.offspring_vial? }

  def self.collect_from_field(vial_params, bit_generator = RandomBitGenerator.new, allele_frequencies = {})
    vial = Vial.new(vial_params)
    allele_frequencies[:sex] = 0.5 unless allele_frequencies[:sex]
    vial.species.characters.each do |character|
      allele_frequencies[character] = 0.13 + (rand 37) / 100.0 unless allele_frequencies[character]
    end
    if vial.save
      vial.fill_from_field(bit_generator, allele_frequencies)
    end
    vial.set_pedigree_number
    vial
  end
  
  def self.make_babies_and_vial(vial_params, bit_generator = RandomBitGenerator.new)
    vial = Vial.new(vial_params.merge({ :offspring_vial => true }))
    if vial.valid?
      vial.save!
      vial.number_of_requested_flies.times do |i|
        vial.flies << vial.mom.mate_with(vial.dad, bit_generator)
      end
    end
    vial.set_pedigree_number
    vial
  end
  
  def offspring_vial=(flag)
    @offspring_vial = flag
  end
  
  def offspring_vial?
    new_record? ? @offspring_vial : has_parents?
  end
  
  def creator=(user)
    @creator = user
  end
  
  def creator
    @creator
  end
  
  def species
    Species.singleton
  end
  
  def has_parents?
    mom
  end
  
  def owner
    rack.owner
  end
  
  def number_of_requested_flies_before_type_cast
    @raw_number_of_requested_flies
  end
  
  def number_of_requested_flies
    @number_of_requested_flies
  end
  
  def number_of_requested_flies=(number)
    @raw_number_of_requested_flies = number
    if (number.blank?)
      @number_of_requested_flies = -1
    else
      @number_of_requested_flies = number.to_i
    end
  end
  
  def get_pedigree_number
    self.set_pedigree_number if self.pedigree_number.nil?
    self.pedigree_number
  end
  
  def set_pedigree_number
    if mom.nil? or dad.nil?
      self.pedigree_number = 1
    else
      self.pedigree_number = mom.vial.get_pedigree_number + dad.vial.get_pedigree_number
    end
  end
  
  def combinations_of_phenotypes(characters = species.characters)
    cartesian_product( characters.collect do |character| 
      phenotypes = phenotypes_for_table(character)
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
    characters.zup(phenotypes) do |character, phenotype|
      #
      alternate = owner.phenotype_alternates.select do |pa|
        pa.affected_character.intern == character and pa.renamed_phenotype.intern == phenotype
      end
      phenotype = alternate.first.original_phenotype.intern if alternate != []
      #
      selection = selection.select do |fly|
        fly.phenotype(character) == phenotype
      end
    end
    selection
  end
  
  def phenotypes_for_table(character)
    species.phenotypes(character).map do |p| 
      renamed_phenotype(character, p).to_s 
    end.sort.map{ |p| p.intern }
  end
  
  def counts_for_table(row_character, column_character)
    counts = {}
    species.phenotypes(row_character).each do |row_phenotype|
      species.phenotypes(column_character).each do |column_phenotype|
        key = renamed_phenotype(row_character, row_phenotype).to_s + "$" + 
            renamed_phenotype(column_character, column_phenotype).to_s
        counts[key] = number_of_flies([row_character, column_character], 
            [row_phenotype, column_phenotype])
      end
    end
    counts
  end
  
  # i don't know that this is the right location for this method...
  def renamed_phenotype(character, phenotype)
    phenotype_alternate = owner.phenotype_alternates.select do |pa|
      pa.scenario_id == owner.current_scenario.id and 
          pa.affected_character.intern == character and pa.original_phenotype.intern == phenotype
    end.first
    if phenotype_alternate
      phenotype_alternate.renamed_phenotype.intern
    else
      phenotype
    end
  end

  def fill_from_field(bit_generator, allele_frequencies)
    number_of_requested_flies.times do |i|
       new_fly = Fly.create!
       species.characters.each do |character|
         if character == :sex # could this be handled better?
           new_fly.genotypes << Genotype.create!(:fly_id => new_fly.id, :gene_number => species.gene_number_of(:sex), 
               :mom_allele => 1, :dad_allele => bit_generator.random_bit(allele_frequencies[:sex]))
         else
           new_fly.genotypes << Genotype.create!(:fly_id => new_fly.id, :gene_number => species.gene_number_of(character), 
               :mom_allele => bit_generator.random_bit(allele_frequencies[character]), 
               :dad_allele => bit_generator.random_bit(allele_frequencies[character]))
         end
       end
       species.characters.each do |character|
         if species.is_sex_linked?(character) and new_fly.male?
           new_fly.genotypes.select { |g| g.gene_number == species.gene_number_of(character) }.first.dad_allele = 0
         end                          # this assumes that 0 represents recessiveness... and some other things
       end
       flies << new_fly
    end
    self
  end
  
  #
  # Helpers
  #
  protected 
  
  def validate_on_create 
    if offspring_vial?
      offspring_vial_validations
    end
  end 
  
  def offspring_vial_validations
    if creator.nil?
      errors.add(:creator, "must specify a user to create the vial")
    else
      if !creator.owns?(rack)
        raise ApplicationController::InvalidOwner.new("rack not owned by the creator")
      end
      if mom && !creator.owns?(mom)
        raise ApplicationController::InvalidOwner.new("mom not owned by the creator")
      end
      if dad && !creator.owns?(dad)
        raise ApplicationController::InvalidOwner.new("dad not owned by the creator")
      end
    end
  end
  
end
