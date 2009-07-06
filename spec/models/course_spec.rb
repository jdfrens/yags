require File.dirname(__FILE__) + '/../spec_helper'

class CourseTest < ActiveSupport::TestCase

  fixtures :all
  
  def test_has_and_belongs_to_many_scenarios
    assert_equal title_sort(scenarios(:first_scenario, :another_scenario, :everything_included)),
        title_sort(courses(:mendels_course).scenarios)
    assert_equal title_sort(scenarios(:only_sex_and_legs, :everything_included)),
        title_sort(courses(:darwins_first_course).scenarios)
  end

  def test_deletion_of_students_along_with_course
    number_of_old_courses = Course.find(:all).size
    number_of_old_users = User.find(:all).size
    assert_equal 1, Course.find(:all, :conditions => "id = 1").size
    assert_equal 3, User.find(:all, :conditions => "course_id = 1").size
    
    courses(:mendels_course).destroy
    assert_equal number_of_old_courses - 1, Course.find(:all).size
    assert_equal 0, Course.find(:all, :conditions => "id = 1").size
    assert_equal 0, User.find(:all, :conditions => "course_id = 1").size
    assert_equal number_of_old_users - 3, User.find(:all).size
  end

  def title_sort(array)
    array.sort_by { |e| e.title }
  end

end
