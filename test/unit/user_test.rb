require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  all_fixtures
  
  def test_has_many_vials
    assert_equal_set [], users(:calvin).vials
    assert_equal_set [vials(:destroyable_vial), vials(:random_vial)], users(:jeremy).vials
    assert_equal_set [:vial_one, :vial_empty, :vial_with_a_fly, :vial_with_many_flies, :parents_vial].map { |s| vials(s) },
        users(:steve).vials  
  end
  
  def test_has_basic_preference
    assert_equal "eye color", users(:jeremy).basic_preference.column
    assert_equal "wings", users(:jeremy).basic_preference.row
    assert_nil users(:keith).basic_preference
  end
  
  def test_has_many_character_preferences
    assert_equal [:"eye color", :wings, :antenna], 
        users(:randy).character_preferences.map { |p| p.hidden_character.intern }
    assert_equal [:legs], 
        users(:jeremy).character_preferences.map { |p| p.hidden_character.intern }
    assert_equal [:seizure], 
        users(:steve).character_preferences.map { |p| p.hidden_character.intern }
  end
  
  def test_solutions
    assert_equal_set [], users(:randy).solutions
    assert_equal_set [solutions(:jeremy_solves_2)], users(:jeremy).solutions
    assert_equal_set [solutions(:steve_solves_1), solutions(:steve_solves_8)], users(:steve).solutions
  end
  
  def test_solutions_as_hash
    assert_equal({}, users(:randy).solutions_as_hash)
    assert_equal({ 2 => solutions(:jeremy_solves_2) }, users(:jeremy).solutions_as_hash)
    assert_equal({ 1 => solutions(:steve_solves_1), 8 => solutions(:steve_solves_8) }, users(:steve).solutions_as_hash)
    assert_equal solutions(:steve_solves_8), users(:steve).solutions_as_hash[8]
    assert_nil users(:steve).solutions_as_hash[5]
    assert_nil users(:steve).solutions_as_hash[9]
  end
  
  def test_owns?
    assert  users(:jeremy).owns?(vials(:destroyable_vial))
    assert !users(:steve).owns?(vials(:destroyable_vial))
    assert !users(:jeremy).owns?(racks(:steve_bench_rack))
    assert  users(:steve).owns?(racks(:steve_bench_rack))
  end
  
  def test_hidden_characters
    assert_equal [:"eye color", :wings, :antenna], users(:randy).hidden_characters
    assert_equal [:legs, :antenna, :seizure], users(:jeremy).hidden_characters
    assert_equal [:seizure], users(:steve).hidden_characters
  end
  
  def test_visible_characters
    assert_equal [:sex, :legs, :seizure], users(:randy).visible_characters
    assert_equal [:sex, :"eye color", :wings], users(:jeremy).visible_characters
    assert_equal [:sex, :"eye color", :wings, :legs, :antenna], users(:steve).visible_characters
    
    assert_equal [], users(:randy).visible_characters([])
    assert_equal [], users(:jeremy).visible_characters([])
    assert_equal [], users(:steve).visible_characters([])
    
    assert_equal [:telekinesis, :legs], users(:randy).visible_characters([:telekinesis, :wings, :legs])
    assert_equal [:telekinesis, :wings], users(:jeremy).visible_characters([:telekinesis, :wings, :legs])
  end
  
  def test_visible_huh
    assert users(:randy).visible?(:sex)
    assert !users(:randy).visible?(:wings)
    assert !users(:randy).visible?(:devil_and_angel_on_shoulders)
    
    assert users(:jeremy).visible?(:wings)
    assert !users(:jeremy).visible?(:legs)
    assert !users(:jeremy).visible?(:internal_bleeding)
  end
  
  def test_student?
    assert !users(:mendel).student?
    assert !users(:calvin).student?
    assert users(:steve).student?
  end
  
  def test_instructor?
    assert users(:mendel).instructor?
    assert !users(:calvin).instructor?
    assert !users(:steve).instructor?
  end
  
  def test_admin?
    assert !users(:mendel).admin?
    assert users(:calvin).admin?
    assert !users(:steve).admin?
  end
  
  def test_students
    assert_equal [users(:jeremy), users(:randy), users(:keith)], users(:mendel).students
    assert_equal [users(:steve)], users(:darwin).students
    assert_equal [], users(:calvin).students
    assert_equal [], users(:steve).students
  end
  
  def test_has_authority_over
    assert users(:mendel).has_authority_over(users(:jeremy))
    assert users(:mendel).has_authority_over(users(:randy))
    assert users(:darwin).has_authority_over(users(:steve))
    assert users(:calvin).has_authority_over(users(:darwin))
    assert users(:calvin).has_authority_over(users(:steve))
    assert users(:steve).has_authority_over(users(:steve))
    assert users(:mendel).has_authority_over(users(:mendel))
    assert users(:calvin).has_authority_over(users(:calvin))
    
    assert !users(:mendel).has_authority_over(users(:steve))
    assert !users(:darwin).has_authority_over(users(:randy))
    assert !users(:darwin).has_authority_over(users(:mendel))
    assert !users(:steve).has_authority_over(users(:darwin))
    assert !users(:randy).has_authority_over(users(:jeremy))
    assert !users(:mendel).has_authority_over(users(:calvin))
  end
  
  def test_current_racks
    assert_equal [], users(:keith).current_racks
    assert_equal ["jeremy bench","jeremy stock"], users(:jeremy).current_racks.map { |r| r.label }.sort
    assert_equal ["steve bench","steve stock"], users(:steve).current_racks.map { |r| r.label }.sort
    assert_equal [], users(:mendel).current_racks
    assert_equal [], users(:calvin).current_racks
  end
  
  def test_add_default_racks_for_current_scenario
    assert users(:randy).current_racks.select{ |r| r.label == "Trash" }.empty?
    assert users(:randy).current_racks.select{ |r| r.label == "Default" }.empty?
    users(:randy).add_default_racks_for_current_scenario
    assert_equal 1, users(:randy).current_racks.select{ |r| r.label == "Trash" }.size
    assert users(:randy).current_racks.select{ |r| r.label == "Default" }.empty?
    
    assert users(:keith).current_racks.select{ |r| r.label == "Trash" }.empty?
    assert users(:keith).current_racks.select{ |r| r.label == "Default" }.empty?
    users(:keith).current_scenario_id = 4
    users(:keith).add_default_racks_for_current_scenario
    assert_equal 1, users(:keith).current_racks.select{ |r| r.label == "Trash" }.size
    assert_equal 1, users(:keith).current_racks.select{ |r| r.label == "Default" }.size
  end
  
  def test_current_scenario
    assert_equal scenarios(:another_scenario), users(:jeremy).current_scenario
    assert_equal scenarios(:everything_included), users(:steve).current_scenario
    assert_nil users(:keith).current_scenario
    assert_nil users(:mendel).current_scenario
    assert_nil users(:calvin).current_scenario
    
    users(:keith).basic_preference = BasicPreference.new(:row => "something", :column => "or other")
    assert_equal "something", users(:keith).basic_preference.row
    assert_nil users(:keith).basic_preference.scenario_id
    assert_nil users(:keith).current_scenario
  end
  
  def test_current_scenario_id=
    users(:steve).current_scenario_id = 2
    users(:steve).reload
    assert_equal Scenario.find(2), users(:steve).current_scenario
    users(:steve).current_scenario_id = 1
    users(:steve).reload
    assert_equal Scenario.find(1), users(:steve).current_scenario
  end
  
  def test_set_scenario_to
    users(:steve).set_scenario_to(2, CookedNumberGenerator.new([1,1]))
    users(:steve).reload
    assert_equal Scenario.find(2), users(:steve).current_scenario
    assert_equal :turquoise, users(:steve).vials.first.renamed_phenotype(:"eye color", :red)
    assert_equal :beige, users(:steve).vials.first.renamed_phenotype(:"eye color", :white)
    assert_equal ["beige", "turquoise"], users(:steve).phenotype_alternates.map { |pa| pa.renamed_phenotype }
    users(:steve).set_scenario_to(1)
    users(:steve).reload
    assert_equal Scenario.find(1), users(:steve).current_scenario
    assert_equal :red, users(:steve).vials.first.renamed_phenotype(:"eye color", :red)
    assert_equal :white, users(:steve).vials.first.renamed_phenotype(:"eye color", :white)
    users(:steve).set_scenario_to(2, CookedNumberGenerator.new([0,4]))
    users(:steve).reload
    assert_equal Scenario.find(2), users(:steve).current_scenario
    assert_equal ["beige", "turquoise"], users(:steve).phenotype_alternates.map { |pa| pa.renamed_phenotype } 
                  # unchanged
  end
 
  def test_set_scenario_to_doesnt_assign_red_and_white_to_blue_and_blue
    users(:steve).set_scenario_to(2, CookedNumberGenerator.new([3,3]))
    users(:steve).reload
    assert_equal Scenario.find(2), users(:steve).current_scenario
    assert_equal ["blue", "green"], users(:steve).phenotype_alternates.map { |pa| pa.renamed_phenotype }
  end
  
  def test_assert_set_scenario_to_adds_default_racks
    assert users(:keith).current_racks.select{ |r| r.label == "Trash" }.empty?
    assert users(:keith).current_racks.select{ |r| r.label == "Default" }.empty?
    users(:keith).set_scenario_to(4)
    assert_equal 1, users(:keith).current_racks.select{ |r| r.label == "Trash" }.size
    assert_equal 1, users(:keith).current_racks.select{ |r| r.label == "Default" }.size
  end
  
  def test_set_character_preferences
    steve = users(:steve)
    steve.set_character_preferences(Species.singleton.characters, ["sex", "antenna"])
    steve.reload
    assert_equal [:sex, :antenna], steve.visible_characters
    steve.set_character_preferences(Species.singleton.characters, ["wings", "antenna", "hooves"])
    steve.reload
    assert_equal [:wings, :antenna], steve.visible_characters
  end
  
  def test_set_character_preferences_resets_table_preferences
    jeremy = users(:jeremy)
    jeremy.set_character_preferences(Species.singleton.characters, ["sex", "eye color"])
    jeremy.reload
    assert_equal [:sex, :"eye color"], jeremy.visible_characters
    assert_nil jeremy.basic_preference.row
    assert_nil jeremy.basic_preference.column
  end
  
  def test_destruction_of_courses_along_with_instructor
    number_of_old_users = User.find(:all).size
    number_of_old_courses = Course.find(:all).size
    number_of_students = User.find(:all).select { |s| s.enrolled_in and s.enrolled_in.instructor_id == 6 }.size
    assert_equal 1, User.find(:all, :conditions => "id = 6").size
    assert_equal 2, Course.find(:all, :conditions => "instructor_id = 6").size
    
    users(:darwin).destroy
    assert_equal number_of_old_users - 1 - number_of_students, User.find(:all).size
    assert_equal 0, User.find(:all, :conditions => "id = 6").size
    assert_equal 0, Course.find(:all, :conditions => "instructor_id = 6").size
    assert_equal number_of_old_courses - 2, Course.find(:all).size
  end
  
  def test_racks_are_destroyed_along_with_student
    assert_dependents_destroyed(User, Rack, :foreign_key => "user_id", 
        :fixture_id => 3, :number_of_dependents => 2)
  end
  
  def test_basic_preference_is_destroyed_along_with_student
    assert_dependents_destroyed(User, BasicPreference, :foreign_key => "user_id", 
        :fixture_id => 3, :number_of_dependents => 1)
  end
  
  def test_character_preferences_are_destroyed_along_with_student
    assert_dependents_destroyed(User, CharacterPreference, :foreign_key => "user_id", 
        :fixture_id => 4, :number_of_dependents => 3)
  end
  
  def test_phenotype_alternates_are_destroyed_along_with_student
    assert_dependents_destroyed(User, PhenotypeAlternate, :foreign_key => "user_id", 
        :fixture_id => 3, :number_of_dependents => 2)
  end
  
end