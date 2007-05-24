require File.dirname(__FILE__) + '/../test_helper'

class VialTest < Test::Unit::TestCase
  fixtures :vials

  def test_label
    assert_equal "First vial", vials(:vial_one).label
  end
  
  def test_validations
    vial = Vial.new
    assert !vial.valid?
    assert vial.errors.invalid?(:label)
  end
end
