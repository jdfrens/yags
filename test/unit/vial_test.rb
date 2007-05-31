require File.dirname(__FILE__) + '/../test_helper'

class VialTest < Test::Unit::TestCase
  fixtures :vials, :flies, :genotypes
  
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
  
end
