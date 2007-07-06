require File.dirname(__FILE__) + '/../test_helper'

class ScenarioTest < Test::Unit::TestCase
  all_fixtures
  
  def test_hidden_characters
    assert_equal [:eye_color, :antenna], scenarios(:first_scenario).hidden_characters
    assert_equal [:antenna], scenarios(:another_scenario).hidden_characters
    assert_equal [:eye_color, :wings, :antenna], scenarios(:only_sex_and_legs).hidden_characters
  end
  
  def test_visible_characters
    assert_equal [:sex, :wings, :legs], scenarios(:first_scenario).visible_characters
    assert_equal [:sex, :eye_color, :wings, :legs], scenarios(:another_scenario).visible_characters
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
  
end
