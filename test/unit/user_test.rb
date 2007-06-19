require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase

  fixtures :users, :vials
  
  def test_has_many_vials
    assert_equal_set [], users(:calvin).vials
    assert_equal_set [vials(:destroyable_vial), vials(:random_vial)], users(:jdfrens).vials
    assert_equal_set [:vial_one, :vial_empty, :vial_with_a_fly, :vial_with_many_flies, :parents_vial].map { |s| vials(s) },
        users(:steve).vials  
  end
  
  def test_has_basic_preference
    assert_equal "eye_color", users(:jdfrens).basic_preference.column
    assert_equal "wings", users(:jdfrens).basic_preference.row
    assert_nil users(:steve).basic_preference
  end
  
end