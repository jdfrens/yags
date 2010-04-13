require File.dirname(__FILE__) + '/../spec_helper'
require 'lab_controller'

# Re-raise errors caught by the controller.
class LabController;
  def rescue_action(e)
    raise e
  end

  ;
end

class LabControllerTest < ActionController::TestCase

  fixtures :all

  def setup
    @controller = LabController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
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

    assert_select "ul" do
      assert_select "li", "Peas pay attention"
    end
  end

  def test_list_courses_as_darwin
    get :list_courses, {}, user_session(:darwin)
    assert_response :success

    assert_select "ul" do
      assert_select "li", "Natural selection"
      assert_select "li", "Interim to the Galapagos Islands"
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

  def test_update_student_solutions_table
    xhr :post, :update_student_solutions_table, { :id => courses(:mendels_course).id }, user_session(:mendel)
    assert_response :success

    assert_select_rjs :replace_html, "table_of_student_solutions" do
      assert_select "table" do
        assert_select "tr th", ""
        assert_select "tr:nth-child(2) th", "jeremy"
        assert_select "tr:nth-child(2) td:nth-child(3)", /X/
        assert_select "tr:nth-child(3) th", "randy"
      end
    end
  end

  def test_update_student_solutions_table_fails_when_NOT_instructors_course
    xhr :post, :update_student_solutions_table, { :id => courses(:darwins_first_course).id }, user_session(:mendel)
    assert_redirected_to :action => 'list_courses'
  end

  def test_update_student_solutions_table_fails_when_NOT_logged_in
    xhr :post, :update_student_solutions_table, { :id => courses(:mendels_course).id }
    assert_redirected_to_login
  end

  def test_choose_course_scenarios_page
    get :choose_course_scenarios, { :id => 3 }, user_session(:darwin)
    assert_response :success

    assert_select "form" do
      assert_select "input[type=checkbox]", 4
      assert_select "input[type=checkbox][checked=checked]", 2
    end
  end

  def test_choose_course_scenarios_works
    assert_equal [1, 2, 4].sort, courses(:mendels_course).scenarios.map { |s| s.id }.sort
    post :choose_course_scenarios, { :id => 1, :scenario_ids => [2, 3] }, user_session(:mendel)
    assert_redirected_to :action => :view_course, :id => 1
    courses(:mendels_course).reload
    assert_equal [2, 3], courses(:mendels_course).scenarios.map { |s| s.id }
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

    assert_select "div#student-vial-info" do
      assert_select "p", "Scenario:#{vials(:random_vial).owner.current_scenario.title}"
      assert_select "p", "Number of offspring:#{vials(:random_vial).flies.size}"
      assert_select "p", "Pedigree number:#{vials(:random_vial).pedigree_number}"

      assert_select "h3", "Genotypes of parents"
      assert_select "p:nth-of-type(4)", "Parents are unknown for field vials."

      assert_select "h2", "Parent Vials"
      assert_select "p:nth-of-type(5)", "Parents are unknown for field vials."
    end
    assert_select "div#student-two-way-table" do
      assert_select "form[action=/lab/update_student_table]" do
        assert_select "select[name=character_col]" do
          assert_select "option[value=eye color]", "eye color"
          assert_select "option[value=wings]", "wings"
        end
        assert_select "select[name=character_row]" do
          assert_select "option[value=eye color]", "eye color"
          assert_select "option[value=wings]", "wings"
        end
        assert_select "div#student-vial-table" do
          assert_select "table" do
            assert_select "tr:nth-child(1) th:nth-child(2)", "beige"
            assert_select "tr:nth-child(1) th:nth-child(3)", "orange"
            assert_select "tr:nth-child(2) th:nth-child(1)", "curly"
            assert_select "tr:nth-child(3) th:nth-child(1)", "straight"
          end
        end
      end
    end
  end

  def test_view_student_vial_again
    get :view_student_vial, {:id => vials(:randy_vial).id }, user_session(:mendel)
    assert_response :success

    assert_select "div#student-vial-info" do
      assert_select "p", "Scenario:#{vials(:randy_vial).owner.current_scenario.title}"
      assert_select "p", "Number of offspring:#{vials(:randy_vial).flies.size}"
      assert_select "p", "Pedigree number:#{vials(:randy_vial).pedigree_number}"

      assert_select "h3", "Genotypes of parents"
      assert_select "p:nth-of-type(4)", "Parents are unknown for field vials."

      assert_select "h2", "Parent Vials"
      assert_select "p:nth-of-type(5)", "Parents are unknown for field vials."
    end
    assert_select "div#student-two-way-table" do
      assert_select "form[action=/lab/update_student_table]" do
        assert_select "select[name=character_col]" do
          assert_select "option[value=sex]", "sex"
          assert_select "option[value=eye color]", "eye color"
          assert_select "option[value=wings]", "wings"
          assert_select "option[value=legs]", "legs"
          assert_select "option[value=antenna]", "antenna"
        end
        assert_select "select[name=character_row]" do
          assert_select "option[value=sex]", "sex"
          assert_select "option[value=eye color]", "eye color"
          assert_select "option[value=wings]", "wings"
          assert_select "option[value=legs]", "legs"
          assert_select "option[value=antenna]", "antenna"
        end
        assert_select "div#student-vial-table" do
          assert_select "img[src^=/images/blank_table.png]"
        end
      end
    end
  end

  def test_view_student_vial_fails_when_NOT_instructor
    get :view_student_vial, {:id => vials(:random_vial).id}
    assert_redirected_to_login

    get :view_student_vial, {:id => vials(:random_vial).id}, user_session(:calvin)
    assert_response 401 # access denied

    get :view_student_vial, {:id => vials(:random_vial).id}, user_session(:randy)
    assert_response 401 # access denied
  end

  def test_view_student_vial_fails_when_NOT_instructors_students_vial
    get :view_student_vial, {:id => vials(:random_vial).id }, user_session(:darwin)
    assert_redirected_to :action => :list_courses # is that what we want?
  end

  def test_update_student_table
    xhr :post, :update_student_table, { :vial_id => vials(:random_vial).id, :character_col => "eye color",
                                        :character_row => "sex" }, user_session(:mendel)
    assert_response :success

    assert_select "table" do
      assert_select "tr:nth-child(1) th:nth-child(2)", "beige"
      assert_select "tr:nth-child(1) th:nth-child(3)", "orange"
      assert_select "tr:nth-child(2) th:nth-child(1)", "female"
      assert_select "tr:nth-child(3) th:nth-child(1)", "male"
    end
  end

  def test_update_student_table_fails_when_NOT_logged_in
    xhr :post, :update_student_table,
        { :vial_id => vials(:random_vial).id, :character_col => "legs",
          :character_row => "wings" }
    assert_redirected_to_login
  end

  def test_update_student_table_fails_when_NOT_instructor_of_student
    xhr :post, :update_student_table, { :vial_id => vials(:random_vial).id, :character_col => "eye color",
                                        :character_row => "sex" }, user_session(:darwin)

    assert_response 401 # permission denied
  end

  def test_update_student_table_restricted_to_xhr_post_only
    assert_xhr_post_only :update_student_table,
                         { :vial_id => vials(:vial_one).id, :character_col => "eye color", :character_row => "sex" },
                         user_session(:mendel)
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

  def test_list_scenarios_redirects_to_list_all
    get :list_scenarios, {}, user_session(:mendel)
    assert_redirected_to :action => "list_scenarios", :id => "all"
  end

  def test_list_all_scenarios
    get :list_scenarios, {:id => "all"}, user_session(:mendel)
    assert_response :success

    assert_select "div#list-scenarios" do
      assert_select "ul" do
        assert_select "li", "forgetful instructor"
        assert_select "li", "party day"
        assert_select "li", "only sex and legs"
        assert_select "li", "everything included"
        assert_select "li img[src^=/images/cross.png]", 2
        assert_select "li", 4
      end
    end
  end

  def test_list_all_scenarios_fails_when_NOT_logged_in_as_instructor
    get :list_scenarios, :id => "all"
    assert_redirected_to_login

    get :list_scenarios, {:id => "all"}, user_session(:calvin)
    assert_response 401 # access denied

    get :list_scenarios, {:id => "all"}, user_session(:steve)
    assert_response 401 # access denied
  end

  def test_list_your_scenarios
    get :list_scenarios, {:id => "your"}, user_session(:mendel)
    assert_response :success

    assert_select "div#list-scenarios" do
      assert_select "ul" do
        assert_select "li", "forgetful instructor"
        assert_select "li", "everything included"
        assert_select "li img[src^=/images/cross.png]", 2
        assert_select "li", 2
      end
    end
  end

  def test_list_your_scenarios_fails_when_NOT_logged_in_as_instructor
    get :list_scenarios, :id => "your"
    assert_redirected_to_login

    get :list_scenarios, {:id => "your"}, user_session(:calvin)
    assert_response 401 # access denied

    get :list_scenarios, {:id => "your"}, user_session(:steve)
    assert_response 401 # access denied
  end

  def test_add_scenario_page
    get :add_scenario, {}, user_session(:mendel)
    assert_response :success

    assert_select "form" do
      assert_select "label[for=species]"
      assert_select "label[for=title]"
      assert_select "script[type=text/javascript]"

      assert_select "input[value=sex]"
      assert_select "input[value=eye color]", 2
      assert_select "input[value=legs]"
      assert_select "input[value=wings]"
      assert_select "input[value=antenna]"
      assert_select "input[value=seizure]"
      assert_select "input[value=1]"
      assert_select "input[type=checkbox]", 8
    end
  end

  def test_add_scenario_works
    number_of_old_scenarios = Scenario.find(:all).size
    post :add_scenario, { :scenario => { :title => "Final Exam" },
                          :characters => [], :alternates => [], :courses => [] }, user_session(:darwin)
    assert_redirected_to :action => "list_scenarios"
    assert_not_nil scenario = Scenario.find_by_title("Final Exam")
    assert_equal number_of_old_scenarios + 1, Scenario.find(:all).size
    users(:darwin).instructs.each do |course|
      assert !course.scenarios.map { |s| s.title }.include?("Final Exam")
    end
    assert_equal [:sex, :"eye color", :wings, :legs, :antenna, :seizure], scenario.hidden_characters
    assert_equal users(:darwin).id, Scenario.find_by_title("Final Exam").owner.id
  end

  def test_add_scenario_works_again
    number_of_old_scenarios = Scenario.find(:all).size
    post :add_scenario, { :scenario => { :title => "Intro to Dominance" },
                          :characters => ["sex", "wings", "eye color"], :alternates => ["eye color"], :courses => ["1"]  },
         user_session(:mendel)
    assert_redirected_to :action => "list_scenarios"
    assert_not_nil scenario = Scenario.find_by_title("Intro to Dominance")
    assert_equal number_of_old_scenarios + 1, Scenario.find(:all).size
    assert Course.find(1).scenarios.map { |s| s.title }.include?("Intro to Dominance")
    assert_equal [:legs, :antenna, :seizure], scenario.hidden_characters
    assert_equal [:"eye color"], scenario.renamed_characters.map { |rc| rc.renamed_character.intern }
    assert_equal users(:mendel).id, Scenario.find_by_title("Intro to Dominance").owner.id
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
    assert_not_nil Scenario.find_by_id(2) # "Party Day"
    post :delete_scenario, { :id => 2 }, user_session(:darwin)
    assert_redirected_to :action => :list_scenarios
    assert_nil Scenario.find_by_id(2)
  end

  def test_delete_scenario_fails_when_NOT_logged_in_as_instructor
    post :delete_scenario, { :id => 1 }
    assert_redirected_to_login

    post :delete_scenario, { :id => 1 }, user_session(:calvin)
    assert_response 401 # access denied

    post :delete_scenario, { :id => 1 }, user_session(:steve)
    assert_response 401 # access denied

    assert_not_nil Scenario.find_by_id(1)
  end

  def test_delete_scenario_fails_when_NOT_instructors_scenario
    post :delete_scenario, { :id => 1 }, user_session(:darwin)
    assert_redirected_to :action => :list_scenarios
    assert_not_nil Scenario.find_by_id(1)
  end

  def test_view_cheat_sheet
    get :view_cheat_sheet, {}, user_session(:mendel)
    assert_response :success

    assert_select "table" do
      assert_select "tr", 7
      assert_select "th", 13
      assert_select "td", 36
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

describe LabController do
  describe "GET index" do
    it "should be successful in rendering template" do
      get :index, {}, user_session(:mendel)

      response.should be_success
      response.should render_template("lab/index")
    end
  end
end
