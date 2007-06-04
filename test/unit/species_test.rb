require File.dirname(__FILE__) + '/../test_helper'

class SpeciesTest < Test::Unit::TestCase
  
  def test_singleton_is_not_nil
    assert_not_nil Species.singleton 
  end
  
end