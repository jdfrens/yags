require File.dirname(__FILE__) + '/../test_helper'

class FlyTest < Test::Unit::TestCase
  fixtures :flies

  def test_phenotype
    assert_equal :white, flies(:fly_00).phenotype
    assert_equal :red, flies(:fly_01).phenotype
    assert_equal :red, flies(:fly_10).phenotype
    assert_equal :red, flies(:fly_11).phenotype
  end
end
