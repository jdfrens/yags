require File.dirname(__FILE__) + '/../spec_helper'

describe Scenario do

  it { should have_many(:scenario_preferences).dependent(:destroy) }
  it { should have_many(:renamed_characters).dependent(:destroy) }
  it { should have_many(:shelves).dependent(:destroy) }

end

class ScenarioTest < ActiveSupport::TestCase

  fixtures :all
  
  def test_hidden_characters
    assert_equal [:"eye color", :antenna], scenarios(:first_scenario).hidden_characters
    assert_equal [:antenna, :seizure], scenarios(:another_scenario).hidden_characters
    assert_equal [:"eye color", :wings, :antenna, :seizure], scenarios(:only_sex_and_legs).hidden_characters
  end
  
  def test_visible_characters
    assert_equal [:sex, :wings, :legs, :seizure], scenarios(:first_scenario).visible_characters
    assert_equal [:sex, :"eye color", :wings, :legs], scenarios(:another_scenario).visible_characters
    assert_equal [:sex, :legs], scenarios(:only_sex_and_legs).visible_characters
  end
  
  def test_has_renamed?
    assert scenarios(:another_scenario).has_renamed?(:"eye color")
    
    assert !scenarios(:first_scenario).has_renamed?(:wings)
    assert !scenarios(:another_scenario).has_renamed?(:legs)
    assert !scenarios(:only_sex_and_legs).has_renamed?(:sex)
  end
  
end
