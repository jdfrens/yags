require File.dirname(__FILE__) + '/../test_helper'

class SpeciesTest < Test::Unit::TestCase
  fixtures :flies
  
  def test_singleton_is_not_nil
    assert_not_nil Species.singleton 
  end
  
  def test_singleton_represents_fruit_fly
    assert_equal [:gender, :eye_color, :wings, :legs], Species.singleton.characters
    assert_equal [:not_possible, :male, :female], Species.singleton.phenotypes(:gender)
    assert_equal [:white, :red, :red], Species.singleton.phenotypes(:eye_color)
    assert_equal [:curly, :straight, :straight], Species.singleton.phenotypes(:wings)
    assert_equal [:smooth, :hairy, :hairy], Species.singleton.phenotypes(:legs)
    assert_equal 0.0, Species.singleton.position_of(:gender)
    assert_equal 0.5, Species.singleton.position_of(:eye_color)
    assert_equal 1.0, Species.singleton.position_of(:wings)
    assert_equal 1.2, Species.singleton.position_of(:legs)
  end
  
end