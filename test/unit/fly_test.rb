require File.dirname(__FILE__) + '/../test_helper'

class FlyTest < Test::Unit::TestCase
  fixtures :flies, :genotypes

  def test_phenotype_eye_color
    assert_equal :white, flies(:fly_00).phenotype(:eye_color)
    assert_equal :red, flies(:fly_01).phenotype(:eye_color)
    assert_equal :red, flies(:fly_10).phenotype(:eye_color)
    assert_equal :red, flies(:fly_11).phenotype(:eye_color)
  end
  
  def test_phenotype_gender
    assert_equal :male, flies(:fly_00).phenotype(:gender)
    assert_equal :male, flies(:fly_01).phenotype(:gender)
    assert_equal :male, flies(:fly_10).phenotype(:gender)
    assert_equal :female, flies(:fly_11).phenotype(:gender)
  end
end
