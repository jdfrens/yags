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

    assert_equal 1, vials(:vial_with_a_fly).flies.size

    flies = vials(:vial_with_many_flies).flies
    assert_equal 3, flies.size
    assert flies.include?(flies(:fly_11))
  end
end
