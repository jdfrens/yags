require File.dirname(__FILE__) + '/../test_helper'
require 'lab_controller'

# Re-raise errors caught by the controller.
class LabController; def rescue_action(e) raise e end; end

class LabControllerTest < Test::Unit::TestCase
  all_fixtures

  def setup
    @controller = LabController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index, {}, user_session(:mendel)
    assert_response :success
    assert_standard_layout
    
    assert_select "ul" do
      assert_select "li", 6
    end
  end
  
  def test_index_fails_when_NOT_logged_in_as_instructor
    post :index
    assert_redirected_to_login
    
    post :index, {}, user_session(:calvin)
    assert_response 401 # access denied
  end
  
  def test_list_courses
    get :list_courses, {}, user_session(:mendel)
    assert_response :success
    assert_standard_layout
    assert_select "ul" do
      assert_select "li", "Peas pay attention[delete]"
    end
  end
  
  def test_list_courses_as_darwin
    get :list_courses, {}, user_session(:darwin)
    assert_response :success
    assert_standard_layout
    assert_select "ul" do
      assert_select "li", "Natural selection[delete]"
      assert_select "li", "Interim to the Galapagos Islands[delete]"
    end
  end
  
  def test_list_courses_fails_when_NOT_logged_in_as_instructor
    get :list_courses
    assert_redirected_to_login
    
    get :list_courses, {}, user_session(:calvin)
    assert_response 401 # access denied
    
    get :list_courses, {}, user_session(:steve)
    assert_response 401 # access denied
  end
  
  def test_add_course
    get :add_course, {}, user_session(:mendel)
    assert_response :success
    assert_standard_layout
    assert_select "form" do
      assert_select "p", "Course Name:"
      assert_select "label[for=name]"
    end
  end
  
  def test_add_course_works
    number_of_old_courses = Course.find(:all).size
    post :add_course, { :course => { :name => "From Muck to Mammals" } }, user_session(:darwin)
    assert_redirected_to :action => "list_courses"
    assert_not_nil Course.find_by_name("From Muck to Mammals")
    assert_equal number_of_old_courses + 1, Course.find(:all).size
  end
  
  def test_add_course_fails_when_NOT_logged_in_as_instructor
    post :add_course, { :course => { :name => "Why Aliens are afraid to visit earth" } }
    assert_redirected_to_login
    
    post :add_course, { :course => { :name => "Byker's Bio Course" } }, user_session(:calvin)
    assert_response 401 # access denied
    
    get :add_course, { :course => { :name => "The art of jean selection" } }, user_session(:manage_bench)
    assert_response 401 # access denied
  end
  
  def test_view_course
    get :view_course, {:id => 1 }, user_session(:mendel)
    assert_response :success
    assert_select "ul" do
      assert_select "li", "jdfrens"
      assert_select "li", "randy"
    end
  end
  
  def test_view_course_fails_when_NOT_logged_in_as_instructor
    get :view_course, {:id => 1 }
    assert_redirected_to_login
    
    get :view_course, {:id => 1 }, user_session(:calvin)
    assert_response 401 # access denied
    
    get :view_course, {:id => 1 }, user_session(:manage_bench)
    assert_response 401 # access denied
  end
  
  def test_view_course_fails_when_NOT_instructors_course
    get :view_course, {:id => 3 }, user_session(:mendel)
    assert_redirected_to :action => "list_courses"
    # or should this lead to a 401 access denied?
    
    get :view_course, {:id => 1000 }, user_session(:darwin)
    assert_redirected_to :action => "list_courses"
  end
  
  def test_delete_course
    assert_not_nil Course.find_by_id(2) # "Natural selection"
    post :delete_course, { :id => 2 }, user_session(:darwin)
    assert_redirected_to :action => :list_courses
    assert_nil Course.find_by_id(2)
    
    # should all students in the course be removed then too?
  end
  
  def test_delete_course_fails_when_NOT_logged_in_as_instructor
    post :delete_course, { :id => 1 }
    assert_redirected_to_login
    
    post :delete_course, { :id => 3 }, user_session(:calvin)
    assert_response 401 # access denied
    
    get :delete_course, { :id => 3 }, user_session(:manage_bench)
    assert_response 401 # access denied
    
    assert_not_nil Course.find_by_id(1) # "Peas pay attention"
    assert_not_nil Course.find_by_id(3) # "Interim to the Galapagos Islands"
  end
  
  def test_delete_course_fails_when_NOT_instructors_course
    get :delete_course, {:id => 3 }, user_session(:mendel)
    assert_redirected_to :action => "list_courses"
    # or should this lead to a 401 access denied?
    assert_not_nil Course.find_by_id(3)
    
    get :delete_course, {:id => 1234 }, user_session(:darwin)
    assert_redirected_to :action => "list_courses"
  end
  
end
