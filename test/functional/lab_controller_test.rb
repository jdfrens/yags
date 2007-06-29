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
      assert_select "li", 9
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
    
    post :add_course, { :course => { :name => "The art of jean selection" } }, user_session(:manage_bench)
    assert_response 401 # access denied
  end
  
  def test_view_course
    get :view_course, {:id => 1 }, user_session(:mendel)
    assert_response :success
    assert_select "ul" do
      assert_select "li", "jdfrens"
      assert_select "li", "randy"
    end
    assert_select "div#table_of_student_solutions"
    assert_select "table" do
      assert_select "tr th", "Students"
      assert_select "tr th:nth-child(2)", "Solutions"
      assert_select "tr:nth-child(2) th", "jdfrens"
      assert_select "tr:nth-child(2) td:nth-child(2)", "12"   
      assert_select "tr:nth-child(3) th", "randy"
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
  end
  
  def test_delete_course_fails_when_NOT_logged_in_as_instructor
    post :delete_course, { :id => 1 }
    assert_redirected_to_login
    
    post :delete_course, { :id => 3 }, user_session(:calvin)
    assert_response 401 # access denied
    
    post :delete_course, { :id => 3 }, user_session(:manage_bench)
    assert_response 401 # access denied
    
    assert_not_nil Course.find_by_id(1) # "Peas pay attention"
    assert_not_nil Course.find_by_id(3) # "Interim to the Galapagos Islands"
  end
  
  def test_delete_course_fails_when_NOT_instructors_course
    post :delete_course, {:id => 3 }, user_session(:mendel)
    assert_redirected_to :action => "list_courses"
    # or should this lead to a 401 access denied?
    assert_not_nil Course.find_by_id(3)
    
    post :delete_course, {:id => 1234 }, user_session(:darwin)
    assert_redirected_to :action => "list_courses"
  end
  
  def test_list_scenarios
    get :list_scenarios, {}, user_session(:mendel)
    assert_response :success
    assert_standard_layout
    assert_select "ul" do
      assert_select "li", "forgetful instructor[delete]"
    end
  end
  
  def test_list_scenarios_fails_when_NOT_logged_in_as_instructor
    get :list_scenarios
    assert_redirected_to_login
    
    get :list_scenarios, {}, user_session(:calvin)
    assert_response 401 # access denied
    
    get :list_scenarios, {}, user_session(:steve)
    assert_response 401 # access denied
  end
  
  def test_add_scenario_page
    get :add_scenario, {}, user_session(:mendel)
    assert_response :success
    assert_standard_layout
    assert_select "form" do
      assert_select "label[for=species]"
      assert_select "label[for=title]"
      
      # these tests might not belong here later when the check boxes are moved to a partial
      assert_select "input#gender[value=visible][checked=checked]"
      assert_select "input#eye_color[value=visible][checked=checked]"
      assert_select "input#wings[value=visible][checked=checked]"
      assert_select "input#legs[value=visible][checked=checked]"
      assert_select "input#antenna[value=visible][checked=checked]"
      assert_select "input[type=checkbox][checked=checked]", 5
    end
  end
  
  def test_add_scenario_works
    number_of_old_scenarios = Scenario.find(:all).size
    post :add_scenario, { :scenario => { :title => "Final Exam" } }, user_session(:darwin)
    assert_redirected_to :action => "list_scenarios"
    assert_not_nil scenario = Scenario.find_by_title("Final Exam")
    assert_equal number_of_old_scenarios + 1, Scenario.find(:all).size
    assert_equal [:gender, :eye_color, :wings, :legs, :antenna], scenario.hidden_characters
  end 
  
  def test_add_scenario_works_again
    number_of_old_scenarios = Scenario.find(:all).size
    post :add_scenario, { :scenario => { :title => "Intro to Dominance" }, 
        :gender => "visible", :wings => "visible" }, user_session(:mendel)
    assert_redirected_to :action => "list_scenarios"
    assert_not_nil scenario = Scenario.find_by_title("Intro to Dominance")
    assert_equal number_of_old_scenarios + 1, Scenario.find(:all).size
    assert_equal [:eye_color, :legs, :antenna], scenario.hidden_characters
  end 
  
  def test_add_scenario_fails_when_NOT_logged_in_as_instructor
    number_of_old_scenarios = Scenario.find(:all)
    post :add_scenario, { :course => { :name => "The Martians have come to Earth" } }
    assert_redirected_to_login
    
    post :add_scenario, { :course => { :name => "Byker's Bio Scenario" } }, user_session(:calvin)
    assert_response 401 # access denied
    
    post :add_scenario, { :course => { :name => "Easy full credit" } }, user_session(:manage_bench)
    assert_response 401 # access denied
    assert_equal number_of_old_scenarios, Scenario.find(:all)
  end
  
  def test_view_scenario
    get :view_scenario, {:id => 1 }, user_session(:mendel)
    assert_response :success
    assert_select "ul" do
      assert_select "li", "gender"
      assert_select "li", "wings"
      assert_select "li", "legs"
    end
  end
  
  def test_view_scenario_fails_when_NOT_logged_in_as_instructor
    get :view_scenario, {:id => 1 }
    assert_redirected_to_login
    
    get :view_scenario, {:id => 1 }, user_session(:calvin)
    assert_response 401 # access denied
    
    get :view_scenario, {:id => 1 }, user_session(:manage_bench)
    assert_response 401 # access denied
  end
  
  def test_view_scenario_fails_when_scenario_DOESNT_exist
    get :view_scenario, {:id => 1111 }, user_session(:mendel)
    assert_redirected_to :action => "list_scenarios"
  end
  
  def test_delete_scenario
    assert_not_nil Scenario.find_by_id(1) # "Forgetful Instructor"
    post :delete_scenario, { :id => 1 }, user_session(:darwin)
    assert_redirected_to :action => :list_scenarios
    assert_nil Scenario.find_by_id(1)
  end
  
  def test_delete_scenario_fails_when_NOT_logged_in_as_instructor
    post :delete_scenario, { :id => 1 }
    assert_redirected_to_login
    
    post :delete_scenario, { :id => 1 }, user_session(:calvin)
    assert_response 401 # access denied
    
    post :delete_scenario, { :id => 1 }, user_session(:manage_bench)
    assert_response 401 # access denied
    
    assert_not_nil Scenario.find_by_id(1)
  end
  
  def test_view_cheat_sheet
    post :view_cheat_sheet, {}, user_session(:mendel)
    assert_response :success
    assert_standard_layout
    assert_select "table" do
      assert_select "tr", 6
      assert_select "th", 10
      assert_select "td", 20
    end
  end
  
    def test_view_cheat_sheet_fails_when_NOT_logged_in_as_instructor
    post :view_cheat_sheet
    assert_redirected_to_login
    
    post :view_cheat_sheet, { }, user_session(:calvin)
    assert_response 401 # access denied
    
    post :view_cheat_sheet, { }, user_session(:manage_bench)
    assert_response 401 # access denied
  end
  
end
