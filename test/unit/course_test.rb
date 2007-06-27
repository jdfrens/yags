require File.dirname(__FILE__) + '/../test_helper'

class CourseTest < Test::Unit::TestCase
  all_fixtures

  def test_deletion_of_students_along_with_course
    number_of_old_courses = Course.find(:all).size
    number_of_old_users = User.find(:all).size
    assert_equal 1, Course.find(:all, :conditions => "id = 1").size
    assert_equal 2, User.find(:all, :conditions => "course_id = 1").size
    
    courses(:mendels_course).destroy
    assert_equal number_of_old_courses - 1, Course.find(:all).size
    assert_equal 0, Course.find(:all, :conditions => "id = 1").size
    assert_equal 0, User.find(:all, :conditions => "course_id = 1").size
    assert_equal number_of_old_users - 2, User.find(:all).size
  end
  
end
