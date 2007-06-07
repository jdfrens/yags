require File.dirname(__FILE__) + '/../test_helper'

class VialTest < Test::Unit::TestCase
  fixtures :vials, :flies, :genotypes
  
  include CartesianProduct
  
  def test_label
    assert_equal "First vial", vials(:vial_one).label
  end
  
  def test_validations
    vial = Vial.new
    assert !vial.valid?
    assert vial.errors.invalid?(:label)
  end
  
  def test_vial_has_many_flies
    assert_equal 0, vials(:vial_empty).flies.size, "should be no flies"
    assert_equal [flies(:fly_01)].to_set, vials(:vial_with_a_fly).flies.to_set
    assert_equal [flies(:fly_00), flies(:fly_10), flies(:fly_11), flies(:bob)].to_set,
        vials(:vial_with_many_flies).flies.to_set 
  end
  
  def test_count_of_flies
    assert_equal 0, vials(:vial_empty).number_of_flies(:eye_color, :white)
    assert_equal 0, vials(:vial_empty).number_of_flies(:eye_color, :red)
    assert_equal 0, vials(:vial_with_a_fly).number_of_flies(:eye_color, :white)
    assert_equal 1, vials(:vial_with_a_fly).number_of_flies(:eye_color, :red)
    assert_equal 1, vials(:vial_with_many_flies).number_of_flies(:eye_color, :white)
    assert_equal 3, vials(:vial_with_many_flies).number_of_flies(:eye_color, :red)
    
    assert_equal 0, vials(:vial_empty).number_of_flies(:gender, :female)
    assert_equal 0, vials(:vial_empty).number_of_flies(:gender, :male)
    assert_equal 0, vials(:vial_with_a_fly).number_of_flies(:gender, :female)
    assert_equal 1, vials(:vial_with_a_fly).number_of_flies(:gender, :male)
    assert_equal 2, vials(:vial_with_many_flies).number_of_flies(:gender, :female)
    assert_equal 2, vials(:vial_with_many_flies).number_of_flies(:gender, :male)
  end
  
  def test_count_of_flies_with_multiple_phenotypes
    assert_equal 0, vials(:vial_empty).number_of_flies([:eye_color, :gender], [:white, :female])
    assert_equal 0, vials(:vial_empty).number_of_flies([:eye_color, :gender], [:white, :male])
    assert_equal 0, vials(:vial_empty).number_of_flies([:eye_color, :gender], [:red, :female])
    assert_equal 0, vials(:vial_empty).number_of_flies([:eye_color, :gender], [:red, :male])
    assert_equal 0, vials(:vial_with_a_fly).number_of_flies([:eye_color, :gender], [:white, :female])
    assert_equal 0, vials(:vial_with_a_fly).number_of_flies([:eye_color, :gender], [:white, :male])
    assert_equal 0, vials(:vial_with_a_fly).number_of_flies([:eye_color, :gender], [:red, :female])
    assert_equal 1, vials(:vial_with_a_fly).number_of_flies([:eye_color, :gender], [:red, :male])
    assert_equal 0, vials(:vial_with_many_flies).number_of_flies([:eye_color, :gender], [:white, :female])
    assert_equal 1, vials(:vial_with_many_flies).number_of_flies([:eye_color, :gender], [:white, :male])
    assert_equal 2, vials(:vial_with_many_flies).number_of_flies([:eye_color, :gender], [:red, :female])
    assert_equal 1, vials(:vial_with_many_flies).number_of_flies([:eye_color, :gender], [:red, :male])
  end
  
  def test_pick_first_fly
    assert_equal flies(:fly_00), vials(:vial_with_many_flies).first_of_type([:eye_color, :gender], [:white, :male])
    assert_equal flies(:fly_11), vials(:vial_with_many_flies).first_of_type([:eye_color, :gender], [:red, :female])
    assert_equal flies(:fly_10), vials(:vial_with_many_flies).first_of_type([:eye_color, :gender], [:red, :male])
  end
  
  def test_destroying_of_vial
    number_of_old_vials = Vial.find(:all).size
    number_of_old_flies = Fly.find(:all).size
    assert_equal 1, destroyable_vial = Vial.find(:all, :conditions => "id = 6").size
    assert_equal 2, Fly.find(:all, :conditions => "vial_id = 6").size
    
    vials(:destroyable_vial).destroy
    assert_equal number_of_old_vials - 1, Vial.find(:all).size
    assert_equal 0, Vial.find(:all, :conditions => "id = 6").size
    assert_equal 0, Fly.find(:all, :conditions => "vial_id = 6").size
  end
  
  def test_combinations_of_phenotypes
    assert_equal [:gender, :eye_color, :wings, :legs], vials(:vial_one).species.characters
    assert_equal cartesian_product([[:not_possible, :male, :female],
                                   [:white, :red], 
                                   [:curly, :straight],
                                   [:smooth, :hairy]]),
                                   vials(:vial_one).combinations_of_phenotypes
    assert_equal cartesian_product([[:not_possible, :male, :female],
                                   [:white, :red]]),
                                   vials(:vial_one).combinations_of_phenotypes([:gender, :eye_color])
    assert_equal cartesian_product([[:white, :red],
                                   [:smooth, :hairy]]),
                                   vials(:vial_one).combinations_of_phenotypes([:eye_color, :legs])
  end
  
  def test_collect_four_flies_from_field
    new_vial = Vial.collect_from_field({ :label => "four fly vial"}, 4, CookedBitGenerator.new([1]))
    assert_equal ([:female] * 4), new_vial.flies.map {|fly| fly.phenotype(:gender)}
    assert_equal ([:red] * 4), new_vial.flies.map {|fly| fly.phenotype(:eye_color)} 
    assert_equal ([:straight] * 4), new_vial.flies.map {|fly| fly.phenotype(:wings)}
    assert_equal ([:hairy] * 4), new_vial.flies.map {|fly| fly.phenotype(:legs)} 
  end
  
  def test_collect_nine_flies_from_field
    new_vial = Vial.collect_from_field({ :label => "nine fly vial"}, 9, 
        CookedBitGenerator.new([0, 1, 0, 0]))
    assert_equal ([:male] * 7 + [:female] * 2).sort_by { |p| p.to_s }, 
        new_vial.flies.map {|fly| fly.phenotype(:gender)}.sort_by { |p| p.to_s }
    assert_equal ([:red] * 5 + [:white] * 4).sort_by { |p| p.to_s },
        new_vial.flies.map {|fly| fly.phenotype(:eye_color)}.sort_by { |p| p.to_s }
    assert_equal ([:straight] * 4 + [:curly] * 5).sort_by { |p| p.to_s },
        new_vial.flies.map {|fly| fly.phenotype(:wings)}.sort_by { |p| p.to_s }
    assert_equal ([:hairy] * 5 + [:smooth] * 4).sort_by { |p| p.to_s },
        new_vial.flies.map {|fly| fly.phenotype(:legs)}.sort_by { |p| p.to_s }
    assert_equal 2, new_vial.flies_of_type([:gender, :legs],[:female, :smooth]).size  # nice
  end
  
  def test_collecting_field_vial_with_allele_frequencies
    recessive_vial = Vial.collect_from_field({ :label => "white-eyed curly and shaven flies"}, 14, 
        RandomBitGenerator.new, { :eye_color => 0.0, :wings => 0.0, :legs => 0.0})
    assert_equal 14, recessive_vial.number_of_flies([:eye_color],[:white])
    assert_equal 14, recessive_vial.number_of_flies([:wings],[:curly])
    assert_equal 14, recessive_vial.number_of_flies([:legs],[:smooth])
    
    dominant_vial = Vial.collect_from_field({ :label => "red-eyed gruff flies"}, 15, 
        RandomBitGenerator.new, { :eye_color => 1.0, :wings => 1.0, :legs => 1.0})
    assert_equal 15, dominant_vial.number_of_flies([:eye_color],[:red])
    assert_equal 15, dominant_vial.number_of_flies([:wings],[:straight])
    assert_equal 15, dominant_vial.number_of_flies([:legs],[:hairy])
    
    strange_male_vial = Vial.collect_from_field({ :label => "wasp flies"}, 16, 
        RandomBitGenerator.new, { :eye_color => 0.0, :gender => 0.0})
    assert_equal 16, strange_male_vial.number_of_flies([:eye_color],[:white])
    assert_equal 16, strange_male_vial.number_of_flies([:gender],[:male])
  end
  
  def test_making_three_babies_and_a_vial
    new_vial = Vial.make_babies_and_vial({ :label => "three fly syblings", 
        :mom_id => "6", :dad_id => "1" }, 3, CookedBitGenerator.new([0]))
    assert_equal ([:female] * 3), new_vial.flies.map {|fly| fly.phenotype(:gender)}
    assert_equal ([:white] * 3), new_vial.flies.map {|fly| fly.phenotype(:eye_color)} 
    assert_equal ([:straight] * 3), new_vial.flies.map {|fly| fly.phenotype(:wings)}
    assert_equal ([:smooth] * 3), new_vial.flies.map {|fly| fly.phenotype(:legs)}
  end
  
  def test_making_seven_babies_and_a_vial
    new_vial = Vial.make_babies_and_vial({ :label => "seven fly syblings", 
        :mom_id => "4", :dad_id => "3" }, 7, CookedBitGenerator.new([0, 1, 0, 1, 1]))
    assert_equal ([:male] * 5 + [:female] * 2).sort_by { |p| p.to_s }, 
        new_vial.flies.map {|fly| fly.phenotype(:gender)}.sort_by { |p| p.to_s }
    assert_equal ([:red] * 7 + [:white] * 0).sort_by { |p| p.to_s },
        new_vial.flies.map {|fly| fly.phenotype(:eye_color)}.sort_by { |p| p.to_s }
    assert_equal ([:straight] * 3 + [:curly] * 4).sort_by { |p| p.to_s },
        new_vial.flies.map {|fly| fly.phenotype(:wings)}.sort_by { |p| p.to_s }
    assert_equal ([:hairy] * 4 + [:smooth] * 3).sort_by { |p| p.to_s },
        new_vial.flies.map {|fly| fly.phenotype(:legs)}.sort_by { |p| p.to_s }
    assert_equal 2, new_vial.flies_of_type([:wings, :legs],[:curly, :smooth]).size
  end
  
end
