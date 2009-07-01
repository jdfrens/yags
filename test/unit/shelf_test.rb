require File.dirname(__FILE__) + '/../test_helper'

class ShelfTest < ActiveSupport::TestCase
  
  fixtures :all

  def test_validations
    shelf = Shelf.new
    
    assert !shelf.valid?
    assert  shelf.errors.invalid?(:label)
    assert  shelf.errors.invalid?(:user_id)
  end
  
  def test_trash?
    assert  shelves(:steve_trash_shelf).trash?
    assert !shelves(:steve_stock_shelf).trash?
  end

  def test_shelf_has_many_vials
    assert_equal [vials(:vial_one), vials(:vial_empty), vials(:vial_with_a_fly),
        vials(:vial_with_many_flies), vials(:parents_vial)], shelves(:steve_bench_shelf).vials
    assert_equal [vials(:destroyable_vial), vials(:random_vial)], shelves(:jeremy_bench_shelf).vials
    assert_equal [vials(:randy_vial)], shelves(:randy_bench_shelf).vials
    assert_equal [], shelves(:randy_stock_shelf).vials
  end
end
