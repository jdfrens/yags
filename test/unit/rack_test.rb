require File.dirname(__FILE__) + '/../test_helper'

class RackTest < Test::Unit::TestCase
  
  all_fixtures

  def test_validations
    rack = Rack.new
    
    assert !rack.valid?
    assert  rack.errors.invalid?(:label)
    assert  rack.errors.invalid?(:user_id)
  end

  def test_rack_has_many_vials
    assert_equal [:vial_one, :vial_empty, :vial_with_a_fly, :vial_with_many_flies, 
        :parents_vial].map { |s| vials(s) }, racks(:steve_bench_rack).vials
    assert_equal [:destroyable_vial, :random_vial].map { |s| vials(s) }, racks(:jeremy_bench_rack).vials
    assert_equal [], racks(:randy_bench_rack).vials
  end
end
