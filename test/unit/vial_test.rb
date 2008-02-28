require File.dirname(__FILE__) + '/../test_helper'

class VialTest < Test::Unit::TestCase

  fixtures :vials, :flies, :genotypes, :users, :racks
  
  include CartesianProduct
  
  should_have_many :flies
  should_belong_to :rack
  should_belong_to :mom
  should_belong_to :dad
  
  should_require_attributes :label
  should_require_attributes :number_of_requested_flies, :message => /is not a number/
  should_require_attributes :rack_id
  
  def test_belongs_to_owner
    assert_equal users(:steve), vials(:parents_vial).owner
    assert_equal users(:steve), vials(:vial_one).owner
    assert_equal users(:jeremy), vials(:destroyable_vial).owner
  end
    
  context "number of requested flies" do
    should "allow numbers between 0 and 256" do
      ["4", "0", "255"].each do |number|
        vial = Vial.new(:label => 'foo', :rack_id => 1,
          :number_of_requested_flies => number
        )
        assert  vial.valid?, "should be valid"
        assert !vial.errors.invalid?(:number_of_requested_flies)
      end
    end
    
    should "reject bad and out of range numbers" do
      ['xxx', '-4', '-1', '256', '888'].each do |number|
        vial = Vial.new(:label => 'foo', :rack_id => 1,
          :number_of_requested_flies => number
        )
        assert !vial.valid?
        assert  vial.errors.invalid?(:number_of_requested_flies)
      end
    end
  
    should "allow for nil when loaded" do
      assert_nil Vial.find(:first).number_of_requested_flies
    end
  end
  
  should "check has_parents?" do
    assert !vials(:vial_one).has_parents?
    assert  vials(:destroyable_vial).has_parents?
  end

  context "counting phenotypes" do
    should "tally single phenotype" do
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
  
    should "tally multiple phenotypes" do
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
  
  context "collecting field vials" do
    should "be able to collect 4 with cooked complete dominance" do
      new_vial = Vial.collect_from_field({
          :label => "four fly vial", :rack_id => 1,
          :number_of_requested_flies => "4" 
        },
        CookedBitGenerator.new([1]))
      assert_equal(([:female] * 4), phenotypes_of(new_vial, :sex))
      assert_equal(([:red] * 4), phenotypes_of(new_vial, :"eye color"))
      assert_equal(([:straight] * 4), phenotypes_of(new_vial, :wings))
      assert_equal(([:hairy] * 4),phenotypes_of(new_vial, :legs))
      assert_equal 1, new_vial.pedigree_number
    end
  
    should "be able to collect 9 flies with cooked genes" do
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
      assert_equal 1, new_vial.pedigree_number
    end
  
    should "react to allele frequencies" do
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
  
    should "see recessive gene for sexed linked gene in males" do
      antenna_flies_vial = Vial.collect_from_field({
          :label => "flies with antenna", :rack_id => 1,
          :number_of_requested_flies => "11" },
        RandomBitGenerator.new,
        { :sex => 0.0, :antenna => 1.0 } )
                          
      antenna_flies_vial.reload
      antenna_flies_vial.flies.each do |fly|
        assert fly.male?
        assert_equal 0, 
          fly.genotypes.detect { |g| g.genotype_for?(:antenna) }.dad_allele
      end
    end
  
    should "let females have whatever for sex linked gene" do
      antenna_flies_vial = Vial.collect_from_field({
          :label => "flies with antenna", :rack_id => 1,
          :number_of_requested_flies => "11" },
        RandomBitGenerator.new,
        { :sex => 1.0, :antenna => 1.0 } )
                          
      antenna_flies_vial.reload
      antenna_flies_vial.flies.each do |fly|
        assert fly.female?
        assert_equal 1, 
          fly.genotypes.detect { |g| g.genotype_for?(:antenna) }.dad_allele
      end
    end
  end
  
  context "making babies and a vial" do  
    should "be able to make three recessive babies" do
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
      assert_equal 2, new_vial.pedigree_number
    end
  
    should "be able to make 7 interesting babies" do
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
      assert_equal 2, new_vial.pedigree_number
    end
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
          assert_equal dad_allele_for(fly, :antenna), Fly.find(dad_id).genotype_for(:antenna).mom_allele
        else
          assert_equal dad_allele_for(fly, :antenna), Fly.find(dad_id).genotype_for(:antenna).dad_allele
        end
      end
    end
  end
  
  context "failures making babies" do
    should "complain about missing data" do
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
    
    should "have a creator" do
      vial = Vial.make_babies_and_vial({
          :label => "failure", :rack_id => 1, 
          :mom_id => 6, :dad_id => 1,
          :number_of_requested_flies => 12 })
      assert !vial.valid?
      assert  vial.errors.invalid?(:creator)
    end
    
    should "have a creator who owns the rack" do
      assert_raise ApplicationController::InvalidOwner do
        Vial.make_babies_and_vial({
            :label => "failure", :rack_id => 1, 
            :mom_id => 8, :dad_id => 9,
            :number_of_requested_flies => 12,
            :creator => users(:jeremy) })
      end
    end
  
    should "have a creator who owns the mom" do
      assert_raise ApplicationController::InvalidOwner do
        Vial.make_babies_and_vial({
            :label => "failure", :rack_id => 4, 
            :mom_id => 4, :dad_id => 9,
            :number_of_requested_flies => 12,
            :creator => users(:jeremy) })
      end
    end
  
    should "have a creator who owns the dad" do
      assert_raise ApplicationController::InvalidOwner do
        Vial.make_babies_and_vial({
            :label => "failure", :rack_id => 4, 
            :mom_id => 8, :dad_id => 1,
            :number_of_requested_flies => 12,
            :creator => users(:jeremy) })
      end
    end
  end
  
end
