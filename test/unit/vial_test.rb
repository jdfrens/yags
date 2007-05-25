require File.dirname(__FILE__) + '/../test_helper'

class VialTest < Test::Unit::TestCase
  fixtures :vials, :flies
  
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
    assert_equal [flies(:fly_00), flies(:fly_10), flies(:fly_11)].to_set,
        vials(:vial_with_many_flies).flies.to_set 
  end
  
  def test_count_of_flies
    assert_equal 0, vials(:vial_empty).number_of_recessive_flies
    assert_equal 0, vials(:vial_with_a_fly).number_of_recessive_flies
    assert_equal 1, vials(:vial_with_many_flies).number_of_recessive_flies
  end
end
