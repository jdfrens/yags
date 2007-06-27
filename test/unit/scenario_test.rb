require File.dirname(__FILE__) + '/../test_helper'

class ScenarioTest < Test::Unit::TestCase
  all_fixtures
  
  def test_hidden_characters
    assert_equal [:eye_color, :antenna], scenarios(:first_scenario).hidden_characters
  end
  
  def test_visible_characters
    assert_equal [:gender, :wings, :legs], scenarios(:first_scenario).visible_characters
  end

  def test_destruction_of_preferences_along_with_scenario
    number_of_old_scenarios = Scenario.find(:all).size
    number_of_old_scenario_preferences = ScenarioPreference.find(:all).size
    assert_equal 1, Scenario.find(:all, :conditions => "id = 1").size
    assert_equal 2, ScenarioPreference.find(:all, :conditions => "scenario_id = 1").size
    
    scenarios(:first_scenario).destroy
    assert_equal number_of_old_scenarios - 1, Scenario.find(:all).size
    assert_equal 0, Scenario.find(:all, :conditions => "id = 1").size
    assert_equal 0, ScenarioPreference.find(:all, :conditions => "scenario_id = 1").size
    assert_equal number_of_old_scenario_preferences - 2, ScenarioPreference.find(:all).size
  end
end
