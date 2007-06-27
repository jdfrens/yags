require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase

#  fixtures :users, :vials, :basic_preferences, :character_preferences
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
    assert_equal [:eye_color, :wings, :antenna], users(:randy).hidden_characters
    assert_equal [:legs], users(:jdfrens).hidden_characters
    assert_equal 0, users(:steve).character_preferences.size
  end
  
  def test_hidden_characters
    assert_equal users(:randy).character_preferences.map { |p| p.hidden_character.intern }, 
        users(:randy).hidden_characters
  end
  
  def test_visible_characters
    assert_equal [:gender, :legs], users(:randy).visible_characters
    assert_equal [:gender, :eye_color, :wings, :antenna], users(:jdfrens).visible_characters
    assert_equal [:gender, :eye_color, :wings, :legs, :antenna], users(:steve).visible_characters
    
    assert_equal [], users(:randy).visible_characters([])
    assert_equal [], users(:jdfrens).visible_characters([])
    assert_equal [], users(:steve).visible_characters([])
    
    assert_equal [:telekinesis, :legs], users(:randy).visible_characters([:telekinesis, :wings, :legs])
    assert_equal [:telekinesis, :wings], users(:jdfrens).visible_characters([:telekinesis, :wings, :legs])
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