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
    
    assert_select "ul.list" do
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
      assert_select "label", "Course Name:"
    assert_select "script[type=text/javascript]"
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
    
    post :add_course, { :course => { :name => "The art of jean selection" } }, user_session(:steve)
    assert_response 401 # access denied
  end
  
  def test_view_course
    get :view_course, {:id => 1 }, user_session(:mendel)
    assert_response :success
    assert_select "h1", "Course: Peas pay attention"
    assert_select "script[type=text/javascript]"
    assert_select "ul" do
      assert_select "li", "jeremy"
      assert_select "li", "randy"
    end
    assert_select "div#table_of_student_solutions"
    assert_select "table" do
      assert_select "tr th", ""
      assert_select "tr:nth-child(2) th", "jeremy"
      assert_select "tr:nth-child(2) td:nth-child(3)", "X"
      assert_select "tr:nth-child(3) th", "randy"
    end
  end
  
  def test_view_course_fails_when_NOT_logged_in_as_instructor
    get :view_course, {:id => 1 }
    assert_redirected_to_login
    
    get :view_course, {:id => 1 }, user_session(:calvin)
    assert_response 401 # access denied
    
    get :view_course, {:id => 1 }, user_session(:steve)
    assert_response 401 # access denied
  end
  
  def test_view_course_fails_when_NOT_instructors_course
    get :view_course, {:id => 3 }, user_session(:mendel)
    assert_redirected_to :action => "list_courses"
    # or should this lead to a 401 access denied?
    
    get :view_course, {:id => 1000 }, user_session(:darwin)
    assert_redirected_to :action => "list_courses"
  end
  
  def test_choose_course_scenarios_page
    get :choose_course_scenarios, { :id => 1 }, user_session(:mendel)
    assert_response :success
    assert_standard_layout
    assert_select "form" do
      assert_select "input[type=checkbox]", 3
      assert_select "input[type=checkbox][checked=checked]", 1
    end
  end
  
  def test_choose_course_scenarios_works
    assert_equal [1], Course.find(1).scenarios.map { |s| s.id }
    post :choose_course_scenarios, { :id => 1, :scenario_ids => [2, 3] }, user_session(:mendel)
    assert_redirected_to :action => :view_course, :id => 1
    assert_equal [2, 3], Course.find(1).scenarios.map { |s| s.id }
  end
  
  def test_choose_course_scenarios_fails_when_NOT_logged_in_as_instructor
    get :choose_course_scenarios, {:id => 1 }
    assert_redirected_to_login
    
    get :choose_course_scenarios, {:id => 1 }, user_session(:calvin)
    assert_response 401 # access denied
    
    get :choose_course_scenarios, {:id => 1 }, user_session(:steve)
    assert_response 401 # access denied
  end
  
  def test_choose_course_scenarios_fails_when_NOT_instructors_course
    get :choose_course_scenarios, {:id => 1 }, user_session(:darwin)
    assert_redirected_to :action => :index
  end
  
  def test_view_student_vial
    get :view_student_vial, {:id => vials(:random_vial).id }, user_session(:mendel)
    assert_response :success
    assert_standard_layout
    
    assert_select "p", "Owner: jeremy"
    assert_select "p", "Rack: jeremy bench"
    assert_select "p", "Solution to: 2"
    
    assert_select "div#pedigree-info table" do
      assert_select "p", "This vial is a field vial.  There are no parents."
    end
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
    
    post :delete_course, { :id => 3 }, user_session(:steve)
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
      assert_select "li", "forgetful instructor"
      assert_select "li img[src^=/images/cross.png]"
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
    assert_select "script[type=text/javascript]"
      
      assert_select "input[value=sex][checked=checked]"
      assert_select "input[value=eye color][checked=checked]", 2
      assert_select "input[value=legs][checked=checked]"
      assert_select "input[value=wings][checked=checked]"
      assert_select "input[value=antenna][checked=checked]"
      assert_select "input[value=seizure][checked=checked]"
      assert_select "input[type=checkbox][checked=checked]", 7
    end
  end
  
  def test_add_scenario_works
    number_of_old_scenarios = Scenario.find(:all).size
    post :add_scenario, { :scenario => { :title => "Final Exam" }, 
        :characters => [], :alternates => [] }, user_session(:darwin)
    assert_redirected_to :action => "list_scenarios"
    assert_not_nil scenario = Scenario.find_by_title("Final Exam")
    assert_equal number_of_old_scenarios + 1, Scenario.find(:all).size
    assert_equal [:sex, :"eye color", :wings, :legs, :antenna, :seizure], scenario.hidden_characters
  end 
  
  def test_add_scenario_works_again
    number_of_old_scenarios = Scenario.find(:all).size
    post :add_scenario, { :scenario => { :title => "Intro to Dominance" }, 
        :characters => ["sex", "wings", "eye color"], :alternates => ["eye color"] }, user_session(:mendel)
    assert_redirected_to :action => "list_scenarios"
    assert_not_nil scenario = Scenario.find_by_title("Intro to Dominance")
    assert_equal number_of_old_scenarios + 1, Scenario.find(:all).size
    assert_equal [:legs, :antenna, :seizure], scenario.hidden_characters
    assert_equal [:"eye color"], scenario.renamed_characters.map { |rc| rc.renamed_character.intern }
  end 
  
  def test_add_scenario_fails_when_NOT_logged_in_as_instructor
    number_of_old_scenarios = Scenario.find(:all)
    post :add_scenario, { :course => { :name => "The Martians have come to Earth" } }
    assert_redirected_to_login
    
    post :add_scenario, { :course => { :name => "Byker's Bio Scenario" } }, user_session(:calvin)
    assert_response 401 # access denied
    
    post :add_scenario, { :course => { :name => "Easy full credit" } }, user_session(:steve)
    assert_response 401 # access denied
    assert_equal number_of_old_scenarios, Scenario.find(:all)
  end
  
  def test_view_scenario
    get :view_scenario, {:id => 1 }, user_session(:mendel)
    assert_response :success
    assert_select "ul" do
      assert_select "li", "sex"
      assert_select "li", "wings"
      assert_select "li", "legs"
    end
  end
  
  def test_view_scenario_fails_when_NOT_logged_in_as_instructor
    get :view_scenario, {:id => 1 }
    assert_redirected_to_login
    
    get :view_scenario, {:id => 1 }, user_session(:calvin)
    assert_response 401 # access denied
    
    get :view_scenario, {:id => 1 }, user_session(:steve)
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
    get :delete_scenario, { :id => 1 }
    assert_redirected_to_login
    
    get :delete_scenario, { :id => 1 }, user_session(:calvin)
    assert_response 401 # access denied
    
    get :delete_scenario, { :id => 1 }, user_session(:steve)
    assert_response 401 # access denied
    
    assert_not_nil Scenario.find_by_id(1)
  end
  
  def test_view_cheat_sheet
    get :view_cheat_sheet, {}, user_session(:mendel)
    assert_response :success
    assert_standard_layout
    assert_select "table" do
      assert_select "tr", 7
      assert_select "th", 11
      assert_select "td", 24
    end
  end
  
  def test_view_cheat_sheet_fails_when_NOT_logged_in_as_instructor
    get :view_cheat_sheet
    assert_redirected_to_login
    
    get :view_cheat_sheet, { }, user_session(:calvin)
    assert_response 401 # access denied
    
    get :view_cheat_sheet, { }, user_session(:steve)
    assert_response 401 # access denied
  end
  
end
