require File.dirname(__FILE__) + '/../test_helper'

class VialTest < Test::Unit::TestCase

  fixtures :vials, :flies, :genotypes, :users, :racks
  
  include CartesianProduct
  
  def test_label
    assert_equal "First vial", vials(:vial_one).label
  end
  
  def test_presence_of_validations
    vial = Vial.new
    assert !vial.valid?
    assert  vial.errors.invalid?(:label)
    assert  vial.errors.invalid?(:number_of_requested_flies)
    assert  vial.errors.invalid?(:rack_id)
  end
  
  def test_number_requested_validations
    ["4", "0", "255"].each do |number|
      vial = Vial.new(:label => 'foo', :rack_id => 1,
                      :number_of_requested_flies => number
                      )
      assert  vial.valid?, "should be valid"
      assert !vial.errors.invalid?(:number_of_requested_flies)
    end
        
    ['xxx', '-4', '-1', '256', '888'].each do |number|
      vial = Vial.new(:label => 'foo', :rack_id => 1,
                      :number_of_requested_flies => number
                      )
      assert !vial.valid?
      assert  vial.errors.invalid?(:number_of_requested_flies)
    end
  end
  
  def test_number_of_requested_flies_can_be_nil_when_loaded
    assert_nil Vial.find(:first).number_of_requested_flies
  end
  
  def test_mom
    assert_nil vials(:vial_one).mom
    assert_equal Fly.find(6), vials(:destroyable_vial).mom
  end
  
  def test_mom
    assert_nil vials(:vial_one).dad
    assert_equal Fly.find(7), vials(:destroyable_vial).dad
  end
  
  def test_has_parents?
    assert !vials(:vial_one).has_parents?
    assert  vials(:destroyable_vial).has_parents?
  end
  
  def test_vial_has_many_flies
    assert_equal 0, vials(:vial_empty).flies.size, "should be no flies"
    assert_equal [flies(:fly_01)].to_set, vials(:vial_with_a_fly).flies.to_set
    assert_equal [flies(:fly_00), flies(:fly_10), flies(:fly_11), flies(:bob)].to_set,
        vials(:vial_with_many_flies).flies.to_set 
  end
  
  def test_count_of_flies
    assert_equal 0, vials(:vial_empty).number_of_flies(:"eye color", :white)
    assert_equal 0, vials(:vial_empty).number_of_flies(:"eye color", :red)
    assert_equal 0, vials(:vial_with_a_fly).number_of_flies(:"eye color", :white)
    assert_equal 1, vials(:vial_with_a_fly).number_of_flies(:"eye color", :red)
    assert_equal 1, vials(:vial_with_many_flies).number_of_flies(:"eye color", :white)
    assert_equal 3, vials(:vial_with_many_flies).number_of_flies(:"eye color", :red)
    
    assert_equal 0, vials(:vial_empty).number_of_flies(:sex, :female)
    assert_equal 0, vials(:vial_empty).number_of_flies(:sex, :male)
    assert_equal 0, vials(:vial_with_a_fly).number_of_flies(:sex, :female)
    assert_equal 1, vials(:vial_with_a_fly).number_of_flies(:sex, :male)
    assert_equal 2, vials(:vial_with_many_flies).number_of_flies(:sex, :female)
    assert_equal 2, vials(:vial_with_many_flies).number_of_flies(:sex, :male)
  end
  
  def test_count_of_flies_with_multiple_phenotypes
    assert_equal 0, vials(:vial_empty).number_of_flies([:"eye color", :sex], [:white, :female])
    assert_equal 0, vials(:vial_empty).number_of_flies([:"eye color", :sex], [:white, :male])
    assert_equal 0, vials(:vial_empty).number_of_flies([:"eye color", :sex], [:red, :female])
    assert_equal 0, vials(:vial_empty).number_of_flies([:"eye color", :sex], [:red, :male])
    assert_equal 0, vials(:vial_with_a_fly).number_of_flies([:"eye color", :sex], [:white, :female])
    assert_equal 0, vials(:vial_with_a_fly).number_of_flies([:"eye color", :sex], [:white, :male])
    assert_equal 0, vials(:vial_with_a_fly).number_of_flies([:"eye color", :sex], [:red, :female])
    assert_equal 1, vials(:vial_with_a_fly).number_of_flies([:"eye color", :sex], [:red, :male])
    assert_equal 0, vials(:vial_with_many_flies).number_of_flies([:"eye color", :sex], [:white, :female])
    assert_equal 1, vials(:vial_with_many_flies).number_of_flies([:"eye color", :sex], [:white, :male])
    assert_equal 2, vials(:vial_with_many_flies).number_of_flies([:"eye color", :sex], [:red, :female])
    assert_equal 1, vials(:vial_with_many_flies).number_of_flies([:"eye color", :sex], [:red, :male])
  end
  
  def test_pick_first_fly
    assert_equal flies(:fly_00), vials(:vial_with_many_flies).first_of_type([:"eye color", :sex], [:white, :male])
    assert_equal flies(:fly_11), vials(:vial_with_many_flies).first_of_type([:"eye color", :sex], [:red, :female])
    assert_equal flies(:fly_10), vials(:vial_with_many_flies).first_of_type([:"eye color", :sex], [:red, :male])
  end
  
  def test_flies_are_destroyed_along_with_vial
    assert_dependents_destroyed(Vial, Fly, :foreign_key => "vial_id", 
        :fixture_id => 6, :number_of_dependents => 2)
  end
  
  def test_combinations_of_phenotypes
    assert_equal [:sex, :"eye color", :wings, :legs, :antenna, :seizure], vials(:vial_one).species.characters
    assert_equal cartesian_product([[:female, :male],
                                   [:red, :white], 
                                   [:curly, :straight],
                                   [:hairy, :smooth],
                                   [:long, :short],
                                   [:"20% seizure", :"40% seizure", :"no seizure"]]),
                                   vials(:vial_one).combinations_of_phenotypes
    assert_equal cartesian_product([[:female, :male],
                                   [:red, :white]]),
                                   vials(:vial_one).combinations_of_phenotypes([:sex, :"eye color"])
    assert_equal cartesian_product([[:red, :white],
                                   [:hairy, :smooth]]),
                                   vials(:vial_one).combinations_of_phenotypes([:"eye color", :legs])
  end

  def test_phenotypes_for_table
    assert_equal [:female, :male], vials(:vial_one).phenotypes_for_table(:sex)
    assert_equal [:red, :white], vials(:vial_one).phenotypes_for_table(:"eye color")
    assert_equal [:curly, :straight], vials(:vial_one).phenotypes_for_table(:wings)
    assert_equal [:female, :male], vials(:random_vial).phenotypes_for_table(:sex)
    assert_equal [:beige, :orange], vials(:random_vial).phenotypes_for_table(:"eye color")
    assert_equal [:hairy, :smooth], vials(:random_vial).phenotypes_for_table(:legs)
    assert_equal [:long, :short], vials(:parents_vial).phenotypes_for_table(:antenna)
    assert_equal [:"20% seizure", :"40% seizure", :"no seizure"], vials(:parents_vial).phenotypes_for_table(:seizure)
  end
  
  def test_counts_for_table
    counts_hash = { "female$red" => 0, "female$white" => 0, "male$red" => 0, "male$white" => 0 }
    assert_equal counts_hash, vials(:vial_empty).counts_for_table(:sex, :"eye color")
    counts_hash = { "female$red" => 2, "female$white" => 0, "male$red" => 1, "male$white" => 1 }
    assert_equal counts_hash, vials(:vial_with_many_flies).counts_for_table(:sex, :"eye color")
    counts_hash = { "curly$short" => 0, "curly$long" => 1, "straight$short" => 1, "straight$long" => 2 }
    assert_equal counts_hash, vials(:vial_with_many_flies).counts_for_table(:wings, :antenna)
    counts_hash = { "short$hairy" => 1, "short$smooth" => 1, "long$hairy" => 0, "long$smooth" => 0 }
    assert_equal counts_hash, vials(:destroyable_vial).counts_for_table(:antenna, :legs)
  end

  def test_renamed_phenotype
    assert_equal :orange, vials(:random_vial).renamed_phenotype(:"eye color", :red)
    assert_equal :beige, vials(:random_vial).renamed_phenotype(:"eye color", :white)
    assert_equal :rainbow, vials(:random_vial).renamed_phenotype(:"eye color", :rainbow)
    assert_equal :male, vials(:random_vial).renamed_phenotype(:sex, :male)
    assert_equal :"poofy smoke", vials(:random_vial).renamed_phenotype(:"teleportation style", :"poofy smoke")
    assert_equal :red, vials(:vial_one).renamed_phenotype(:"eye color", :red)
  end
  
  def test_collect_four_flies_from_field
    new_vial = Vial.collect_from_field({
                  :label => "four fly vial", :rack_id => 1,
                  :number_of_requested_flies => "4" 
                  },
                  CookedBitGenerator.new([1]))
    assert_equal(([:female] * 4), phenotypes_of(new_vial, :sex))
    assert_equal(([:red] * 4), phenotypes_of(new_vial, :"eye color"))
    assert_equal(([:straight] * 4), phenotypes_of(new_vial, :wings))
    assert_equal(([:hairy] * 4),phenotypes_of(new_vial, :legs))
  end
  
  def test_collect_nine_flies_from_field
    new_vial = Vial.collect_from_field({
                 :label => "nine fly vial", :rack_id => 1,
                 :number_of_requested_flies => "9" },
                 CookedBitGenerator.new([0, 1, 0, 0]))
    assert_equal_set(([:male] * 7 + [:female] * 2), 
        new_vial.flies.map {|fly| fly.phenotype(:sex)})
    assert_equal_set(([:red] * 5 + [:white] * 4),
        new_vial.flies.map {|fly| fly.phenotype(:"eye color")})
    assert_equal_set(([:straight] * 4 + [:curly] * 5),
        new_vial.flies.map {|fly| fly.phenotype(:wings)})
    assert_equal_set(([:hairy] * 5 + [:smooth] * 4),
        new_vial.flies.map {|fly| fly.phenotype(:legs)})
    assert_equal_set(([:long] * 4 + [:short] * 5),
        new_vial.flies.map {|fly| fly.phenotype(:antenna)})
    assert_equal 2, new_vial.flies_of_type([:sex, :legs],[:female, :smooth]).size
  end
  
  def test_collecting_field_vial_with_allele_frequencies
    recessive_vial = Vial.collect_from_field({
                        :label => "white-eyed curly and shaven flies",
                        :rack_id => 1,
                        :number_of_requested_flies => "14" },
                        RandomBitGenerator.new,
                        { :"eye color" => 0.0, :wings => 0.0, :legs => 0.0} )
    assert_equal 14, recessive_vial.number_of_flies([:"eye color"],[:white])
    assert_equal 14, recessive_vial.number_of_flies([:wings],[:curly])
    assert_equal 14, recessive_vial.number_of_flies([:legs],[:smooth])
    
    dominant_vial = Vial.collect_from_field({
                       :label => "red-eyed gruff flies", :rack_id => 1,
                       :number_of_requested_flies => '15' },
                       RandomBitGenerator.new,
                       { :"eye color" => 1.0, :wings => 1.0, :legs => 1.0} )
    assert_equal 15, dominant_vial.number_of_flies([:"eye color"],[:red])
    assert_equal 15, dominant_vial.number_of_flies([:wings],[:straight])
    assert_equal 15, dominant_vial.number_of_flies([:legs],[:hairy])
    
    strange_male_vial = Vial.collect_from_field({
                           :label => "wasp flies", :rack_id => 1,
                           :number_of_requested_flies => 16 },
                           RandomBitGenerator.new,
                           { :"eye color" => 0.0, :sex => 0.0} )
    assert_equal 16, strange_male_vial.number_of_flies([:"eye color"],[:white])
    assert_equal 16, strange_male_vial.number_of_flies([:sex],[:male])
  end
  
  def test_sex_linkage_in_field_vials
    antenna_flies_vial = Vial.collect_from_field({
                            :label => "flies with antenna", :rack_id => 1,
                            :number_of_requested_flies => "11" },
                            RandomBitGenerator.new,
                            { :sex => 0.0 } )
    antenna_flies_vial.flies.each do |fly|
      fly_dad_allele = fly.genotypes.select do |g| 
        g.gene_number == fly.species.gene_number_of(:antenna) 
      end.first.dad_allele
      assert_equal 0, fly_dad_allele
    end
  end
  
  def test_making_three_babies_and_a_vial
    new_vial = Vial.make_babies_and_vial({
                  :label => "three fly syblings", :rack_id => 1, 
                  :mom_id => "6", :dad_id => "1",
                  :number_of_requested_flies => "3",
                  :creator => users(:steve) }, 
                  CookedBitGenerator.new([0]) )
                  
    assert new_vial.valid?
    assert_equal(([:female] * 3), phenotypes_of(new_vial, :sex))
    assert_equal(([:white] * 3), phenotypes_of(new_vial, :"eye color"))
    assert_equal(([:straight] * 3), phenotypes_of(new_vial, :wings))
    assert_equal(([:smooth] * 3), phenotypes_of(new_vial, :legs))
  end
  
  def test_making_seven_babies_and_a_vial
    new_vial = Vial.make_babies_and_vial({
                  :label => "seven fly syblings", :rack_id => 1,
                  :mom_id => "4", :dad_id => "3",
                  :number_of_requested_flies => "7",
                  :creator => users(:steve) },
                  CookedBitGenerator.new([0,1,1,0,0,0,1]) )
                  
    assert new_vial.valid?
    assert_equal_set(([:male] * 3 + [:female] * 4), 
        new_vial.flies.map {|fly| fly.phenotype(:sex)})
    assert_equal_set(([:red] * 7 + [:white] * 0),
        new_vial.flies.map {|fly| fly.phenotype(:"eye color")})
    assert_equal_set(([:straight] * 3 + [:curly] * 4),
        new_vial.flies.map {|fly| fly.phenotype(:wings)})
    assert_equal_set(([:hairy] * 4 + [:smooth] * 3),
        new_vial.flies.map {|fly| fly.phenotype(:legs)})
    assert_equal_set(([:long] * 7 + [:short] * 0),
        new_vial.flies.map {|fly| fly.phenotype(:antenna)})
    assert_equal_set(([:"no seizure"] * 1 + [:"20% seizure"] * 4 + [:"40% seizure"] * 2),
        new_vial.flies.map {|fly| fly.phenotype(:seizure)})
    assert_equal 2, new_vial.flies_of_type([:wings, :legs],[:curly, :smooth]).size
  end
  
  def test_offspring_vial?
    new_vial = Vial.make_babies_and_vial({
                  :label => "three fly syblings", :rack_id => 1, 
                  :mom_id => "6", :dad_id => "1",
                  :number_of_requested_flies => "3" }, 
                  CookedBitGenerator.new([0]) )
    assert new_vial.offspring_vial?,
        "should be an offspring vial because of the method called to create it"

    new_vial = Vial.make_babies_and_vial({
                  :label => "seven fly syblings", :rack_id => 1,
                  :mom_id => "4", :dad_id => "3",
                  :number_of_requested_flies => "7" },
                  CookedBitGenerator.new([0,1,1,0,0,0,1]) )
    assert new_vial.offspring_vial?,
        "should be an offspring vial because of the method called to create it"
    
    assert !vials(:vial_one).offspring_vial?
    assert !vials(:vial_with_many_flies).offspring_vial?
    assert  vials(:destroyable_vial).offspring_vial?,
        "should give sane answer for vials from database with parents"
  end
  
  def test_sex_linkage_of_antenna
    mom_ids = [4, 6, 8]; dad_ids = [3, 7, 10]
    mom_ids.zup(dad_ids) do |mom_id, dad_id|
      children_vial = Vial.make_babies_and_vial({
          :label => "sex linkage test vial", :rack_id => 1, 
          :mom_id => mom_id, :dad_id => dad_id,
          :number_of_requested_flies => 12 })
      
      children_vial.flies.each do |fly|
        if fly.female?
          assert_equal dad_allele_for(fly, :antenna), mom_allele_for(Fly.find(dad_id), :antenna)
        else # if male?
          assert_equal dad_allele_for(fly, :antenna), dad_allele_for(Fly.find(dad_id), :antenna)
        end
      end
    end
  end
  
  def test_make_babies_and_vial_fails_missing_data_validations
    vial = Vial.make_babies_and_vial({
          :label => "failure", :rack_id => 1, 
          :mom_id => nil, :dad_id => nil,
          :number_of_requested_flies => -12,
          :creator => users(:steve) })
    assert !vial.valid?
    assert  vial.errors.invalid?(:number_of_requested_flies)
    assert  vial.errors.invalid?(:mom_id), "mom should not be missing"
    assert  vial.errors.invalid?(:dad_id), "dad should not be missing"
  end
    
  def test_make_babies_and_vial_fails_missing_creator
    vial = Vial.make_babies_and_vial({
          :label => "failure", :rack_id => 1, 
          :mom_id => 6, :dad_id => 1,
          :number_of_requested_flies => 12 })
    assert !vial.valid?
    assert  vial.errors.invalid?(:creator)
  end
    
  def test_make_babies_and_vial_fails_security_validations
    vial = Vial.make_babies_and_vial({
          :label => "failure", :rack_id => 1, 
          :mom_id => 6, :dad_id => 1,
          :number_of_requested_flies => 12,
          :creator => users(:jeremy) })
    assert !vial.valid?
    assert  vial.errors.invalid?(:rack), "should not put on rack not owned by creator"
    assert  vial.errors.invalid?(:mom_id), "should not use fly not owned by creator"
    assert  vial.errors.invalid?(:dad_id), "should not use fly not owned by creator"
  end
  
  def test_belongs_to_owner
    assert_equal users(:steve), vials(:parents_vial).owner
    assert_equal users(:steve), vials(:vial_one).owner
    assert_equal users(:jeremy), vials(:destroyable_vial).owner
  end

  #
  # Helpers
  #
  private
  
  # maybe should this be a full fledged method in the Fly class instead of a helper?
  def dad_allele_for(fly, character)
    fly.genotypes.select { |g| g.gene_number == fly.species.gene_number_of(character) }.first.dad_allele
  end
  
  # and so that there is only one of them, we could make a genotype_for instead
  def mom_allele_for(fly, character)
    fly.genotypes.select { |g| g.gene_number == fly.species.gene_number_of(character) }.first.mom_allele
  end
  
end
