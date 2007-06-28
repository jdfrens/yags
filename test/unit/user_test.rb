require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  all_fixtures
  
  def test_has_many_vials
    assert_equal_set [], users(:calvin).vials
    assert_equal_set [vials(:destroyable_vial), vials(:random_vial)], users(:jdfrens).vials
    assert_equal_set [:vial_one, :vial_empty, :vial_with_a_fly, :vial_with_many_flies, :parents_vial].map { |s| vials(s) },
        users(:steve).vials  
  end
  
  def test_has_basic_preference
    assert_equal "eye_color", users(:jdfrens).basic_preference.column
    assert_equal "wings", users(:jdfrens).basic_preference.row
    assert_nil users(:steve).basic_preference
  end
  
  def test_has_many_character_preferences
    assert_equal [:eye_color, :wings, :antenna], 
        users(:randy).character_preferences.map { |p| p.hidden_character.intern }
    assert_equal [:legs], 
        users(:jdfrens).character_preferences.map { |p| p.hidden_character.intern }
    assert_equal 0, users(:steve).character_preferences.size
  end
  
  def test_hidden_characters
    assert_equal [:eye_color, :wings, :antenna], users(:randy).hidden_characters
    assert_equal [:legs, :antenna], users(:jdfrens).hidden_characters
    assert_equal [], users(:steve).hidden_characters
  end
  
  def test_visible_characters
    assert_equal [:gender, :legs], users(:randy).visible_characters
    assert_equal [:gender, :eye_color, :wings], users(:jdfrens).visible_characters
    assert_equal [:gender, :eye_color, :wings, :legs, :antenna], users(:steve).visible_characters
    
    assert_equal [], users(:randy).visible_characters([])
    assert_equal [], users(:jdfrens).visible_characters([])
    assert_equal [], users(:steve).visible_characters([])
    
    assert_equal [:telekinesis, :legs], users(:randy).visible_characters([:telekinesis, :wings, :legs])
    assert_equal [:telekinesis, :wings], users(:jdfrens).visible_characters([:telekinesis, :wings, :legs])
  end
  
  def test_is_visible
    assert users(:randy).is_visible(:gender)
    assert !users(:randy).is_visible(:wings)
    assert !users(:randy).is_visible(:devil_and_angel_on_shoulders)
    
    assert users(:jdfrens).is_visible(:wings)
    assert !users(:jdfrens).is_visible(:legs)
    assert !users(:jdfrens).is_visible(:internal_bleeding)
  end
  
  def test_instructor?
    assert users(:mendel).instructor?
    assert !users(:calvin).instructor?
    assert !users(:steve).instructor?
  end
  
  def test_students
    # these tests could use some more fixture entries to make them more rigorous
    assert_equal [users(:jdfrens), users(:randy)], users(:mendel).students
    assert_equal [users(:steve)], users(:darwin).students
    assert_equal [], users(:calvin).students
    assert_equal [], users(:steve).students
  end
  
  def test_has_authority_over
    assert users(:mendel).has_authority_over(users(:jdfrens))
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
    assert !users(:randy).has_authority_over(users(:jdfrens))
    assert !users(:mendel).has_authority_over(users(:calvin))
  end
  
  def test_current_scenario
    assert_equal scenarios(:another_scenario), users(:jdfrens).current_scenario
    assert_nil users(:steve).current_scenario
    assert_nil users(:mendel).current_scenario
    assert_nil users(:calvin).current_scenario
  end
  
  def test_current_scenario_id=
    users(:steve).current_scenario_id = 2
    users(:steve).reload
    assert_equal Scenario.find(2), users(:steve).current_scenario
    users(:steve).current_scenario_id = 1
    users(:steve).reload
    assert_equal Scenario.find(1), users(:steve).current_scenario
  end
  
  def test_destruction_of_courses_along_with_instructor
    number_of_old_users = User.find(:all).size
    number_of_old_courses = Course.find(:all).size
    number_of_students = User.find(:all).select { |s| s.course and s.course.instructor_id == 6 }.size
    assert_equal 1, User.find(:all, :conditions => "id = 6").size
    assert_equal 2, Course.find(:all, :conditions => "instructor_id = 6").size
    
    users(:darwin).destroy
    assert_equal number_of_old_users - 1 - number_of_students, User.find(:all).size
    assert_equal 0, User.find(:all, :conditions => "id = 6").size
    assert_equal 0, Course.find(:all, :conditions => "instructor_id = 6").size
    assert_equal number_of_old_courses - 2, Course.find(:all).size
  end
  
  def test_destruction_of_racks_along_with_student
    number_of_old_users = User.find(:all).size
    number_of_old_racks = Rack.find(:all).size
    assert_equal 1, User.find(:all, :conditions => "id = 3").size
    assert_equal 2, Rack.find(:all, :conditions => "user_id = 3").size
    
    users(:jdfrens).destroy
    assert_equal number_of_old_users - 1, User.find(:all).size
    assert_equal 0, User.find(:all, :conditions => "id = 3").size
    assert_equal 0, Rack.find(:all, :conditions => "user_id = 3").size
    assert_equal number_of_old_racks - 2, Rack.find(:all).size
  end
  
  def test_destruction_of_basic_preference_along_with_student
    number_of_old_users = User.find(:all).size
    number_of_old_basic_preferences = BasicPreference.find(:all).size
    assert_equal 1, User.find(:all, :conditions => "id = 3").size
    assert_equal 1, BasicPreference.find(:all, :conditions => "user_id = 3").size
    
    users(:jdfrens).destroy
    assert_equal number_of_old_users - 1, User.find(:all).size
    assert_equal 0, User.find(:all, :conditions => "id = 3").size
    assert_equal 0, BasicPreference.find(:all, :conditions => "user_id = 3").size
    assert_equal number_of_old_basic_preferences - 1, BasicPreference.find(:all).size
  end
  
  def test_destruction_of_character_preferences_along_with_student
    number_of_old_users = User.find(:all).size
    number_of_old_character_preferences = CharacterPreference.find(:all).size
    assert_equal 1, User.find(:all, :conditions => "id = 4").size
    assert_equal 3, CharacterPreference.find(:all, :conditions => "user_id = 4").size
    
    users(:randy).destroy
    assert_equal number_of_old_users - 1, User.find(:all).size
    assert_equal 0, User.find(:all, :conditions => "id = 4").size
    assert_equal 0, CharacterPreference.find(:all, :conditions => "user_id = 4").size
    assert_equal number_of_old_character_preferences - 3, CharacterPreference.find(:all).size
  end
  
end