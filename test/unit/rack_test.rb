require File.dirname(__FILE__) + '/../test_helper'

class RackTest < ActiveSupport::TestCase
  
  all_fixtures

  def test_validations
    rack = Rack.new
    
    assert !rack.valid?
    assert  rack.errors.invalid?(:label)
    assert  rack.errors.invalid?(:user_id)
  end
  
  def test_trash?
    assert racks(:steve_trash_rack).trash?
    assert !racks(:steve_stock_rack).trash?
  end

  def test_rack_has_many_vials
    assert_equal [vials(:vial_one), vials(:vial_empty), vials(:vial_with_a_fly),
        vials(:vial_with_many_flies), vials(:parents_vial)], racks(:steve_bench_rack).vials
    assert_equal [vials(:destroyable_vial), vials(:random_vial)], racks(:jeremy_bench_rack).vials
    assert_equal [vials(:randy_vial)], racks(:randy_bench_rack).vials
    assert_equal [], racks(:randy_stock_rack).vials
  end
end
