require File.dirname(__FILE__) + '/../test_helper'

class ScenarioTest < Test::Unit::TestCase
  all_fixtures
  
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
  
  def test_scenarios_preferences_are_dependently_destroyed
    assert_dependents_destroyed(Scenario, ScenarioPreference, :foreign_key => "scenario_id", 
        :fixture_id => 1, :number_of_dependents => 2)
  end
  
  def test_renamed_characters_are_dependently_destroyed
    assert_dependents_destroyed(Scenario, RenamedCharacter, :foreign_key => "scenario_id", 
        :fixture_id => 2, :number_of_dependents => 1)
  end
  
  def test_has_renamed?
    assert scenarios(:another_scenario).has_renamed?(:"eye color")
    
    assert !scenarios(:first_scenario).has_renamed?(:wings)
    assert !scenarios(:another_scenario).has_renamed?(:legs)
    assert !scenarios(:only_sex_and_legs).has_renamed?(:sex)
  end
  
end
