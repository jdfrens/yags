require File.dirname(__FILE__) + '/../test_helper'

class SpeciesTest < Test::Unit::TestCase
  fixtures :flies
  
  def test_singleton_is_not_nil
    assert_not_nil Species.singleton 
  end
  
  def test_singleton_represents_fruit_fly
    assert_equal [:gender, :eye_color, :wings], flies(:fly_00).species.characters
    assert_equal [:not_possible, :male, :female], flies(:fly_00).species.phenotypes(:gender)
    assert_equal [:white, :red, :red], flies(:fly_00).species.phenotypes(:eye_color)
  end
  
end