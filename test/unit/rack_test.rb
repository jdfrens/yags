require File.dirname(__FILE__) + '/../test_helper'

class RackTest < Test::Unit::TestCase
  fixtures :racks, :vials

  def test_rack_has_many_vials
    assert_equal [:vial_one, :vial_empty, :vial_with_a_fly, :vial_with_many_flies, 
        :parents_vial].map { |s| vials(s) }, racks(:steve_rack).vials
    assert_equal [:destroyable_vial, :random_vial].map { |s| vials(s) }, racks(:jdfrens_rack).vials
    assert_equal [], racks(:randy_rack).vials
  end
end
