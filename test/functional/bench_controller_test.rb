require File.dirname(__FILE__) + '/../test_helper'
require 'bench_controller'

# Re-raise errors caught by the controller.
class BenchController; def rescue_action(e) raise e end; end

class BenchControllerTest < Test::Unit::TestCase
  all_fixtures
  
  def setup
    @controller = BenchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_collect_field_vial_of_four_flies
    number_of_old_vials =  Vial.find(:all).size
    post :collect_field_vial, { :vial => { :label => "four fly vial"}, :number => "4" }, user_session(:manage_bench)
    new_vial = Vial.find_by_label("four fly vial")
    assert_not_nil new_vial
    assert_equal number_of_old_vials + 1, Vial.find(:all).size
    assert_equal 4, new_vial.flies.size
    assert_equal 1, new_vial.user_id
    assert_response :redirect
    assert_redirected_to :action => "view_vial", :id => new_vial.id
  end
  
  def test_collect_field_vial_of_nine_flies
    number_of_old_vials =  Vial.find(:all).size
    post :collect_field_vial, { :vial => { :label => "nine fly vial" }, :number => "9" }, user_session(:manage_bench)
    assert logged_in?, "should be logged in"
    new_vial = Vial.find_by_label("nine fly vial")
    assert_not_nil new_vial
    assert_equal number_of_old_vials + 1, Vial.find(:all).size
    assert_equal 9, new_vial.flies.size
    assert_equal 1, new_vial.user_id
    assert_response :redirect
    assert_redirected_to :action => "view_vial", :id => new_vial.id
  end
  
  def test_collect_field_vial_fails_when_NOT_logged_in
    post :collect_field_vial, { :vial => { :label => "anonomous user's vial"}, :number => "8" }
    assert_redirected_to_login
  end

  def test_collect_field_vial_fails_if_number_invalid
    post :collect_field_vial, { :vial => { :label => "some vial"}, :number => "581" }, user_session(:manage_bench)
    assert !flash.empty?
    assert_equal "The number of flies should be between 0 and 255.",  flash[:error]
  end

  def test_collect_field_vial_page
    post :collect_field_vial, {}, user_session(:manage_bench)
    assert_response :success
    assert_standard_layout
    
    assert_select "form" do
      assert_select "p", "Label:"
      assert_select "label"
      assert_select "p", "Number of Flies:"
      assert_select "input"
    end
  end
  
  def test_add_rack
    number_of_old_racks =  Rack.find(:all).size
    post :add_rack, { :rack => { :label => "super storage unit"} }, user_session(:manage_bench)
    new_rack = Rack.find_by_label("super storage unit")
    assert_not_nil new_rack
    assert_equal number_of_old_racks + 1, Rack.find(:all).size
    assert_equal 1, new_rack.user_id
    assert_response :redirect
    assert_redirected_to :action => "list_vials"
  end
  
  def test_add_rack_fails_when_NOT_logged_in
    post :add_rack, { :rack => { :label => "super duper unit"} }
    assert_redirected_to_login
  end

  def test_add_rack_page
    get :add_rack, {}, user_session(:manage_bench)
    assert_response :success
    assert_standard_layout
    
    assert_select "form" do
      assert_select "p", "Label:"
      assert_select "label"
    end
  end
  
  def test_move_vial_to_another_rack_page
    get :move_vial_to_another_rack, { :id => 5 }, user_session(:steve)
    assert_response :success
    assert_standard_layout
    
    assert_select "form" do
      assert_select "select#rack_id" do
        assert_select "option", 2
      end
    end
  end
  
  def test_move_vial_to_another_rack
    number_of_old_vials_in_rack = Rack.find(1).vials.size
    post :move_vial_to_another_rack, { :id => 5, :rack_id => 1 }, user_session(:steve)
    assert_equal number_of_old_vials_in_rack + 1, Rack.find(1).vials.size
    assert_equal 1, Vial.find(5).rack_id
    assert_response :redirect
    assert_redirected_to :action => "view_vial", :id => 5
  end
  
  def test_move_vial_to_another_rack_fails_when_NOT_logged_in
    post :move_vial_to_another_rack, { :id => 4, :rack_id => 1 }
    assert_redirected_to_login
  end
  
  def test_move_vial_to_another_rack_fails_when_NOT_owner_of_vial
    post :move_vial_to_another_rack, { :id => 7, :rack_id => 1 }, user_session(:steve)
    assert_redirected_to :action => "list_vials"
  end
  
  def test_move_vial_to_another_rack_fails_when_NOT_owner_of_rack
    post :move_vial_to_another_rack, { :id => 3, :rack_id => 5 }, user_session(:steve)
    assert_redirected_to :action => "list_vials"
  end
  
  def test_view_vial_with_a_fly
    get :view_vial, { :id => vials(:vial_with_a_fly).id }, user_session(:manage_bench)
    assert_response :success
    assert_standard_layout
    assert_select "span#vial_label_3_in_place_editor", vials(:vial_with_a_fly).label
    assert_select "p", "Rack: steve bench"
        
    assert_select "div#vial-table"
    assert_select "div#parent-info"
    assert_select "div#parent-info table" do
      assert_select "p", "No parents!"
    end
    assert_select "div#solution_notice", ""
  end
  
  def test_view_vial_with_many_flies
    get :view_vial, { :id => vials(:vial_with_many_flies).id }, user_session(:manage_bench)
    assert_response :success
    assert_standard_layout
    assert_select "span#vial_label_4_in_place_editor", vials(:vial_with_many_flies).label
    assert_select "p", "Rack: steve bench"
    
    assert_select "div#vial-table"
    assert_select "div#parent-info"
    assert_select "div#parent-info table" do
      assert_select "p", "No parents!"
    end
    assert_select "div#solution_notice", ""
  end
  
  def test_view_vial_one
    get :view_vial, { :id => vials(:vial_one).id }, user_session(:manage_bench)
    assert_response :success
    assert_standard_layout
    assert_select "span#vial_label_1_in_place_editor", vials(:vial_one).label
    assert_select "p", "Rack: steve bench"
    
    assert_select "div#vial-table"
    assert_select "div#parent-info"
    assert_select "div#parent-info table" do
      assert_select "p", "No parents!"
    end
    assert_select "div#solution_notice", "This is a solution to problem 8."
  end
  
  def test_view_vial_fails_when_NOT_logged_in
    get :view_vial, { :id => vials(:vial_one).id }
    assert_redirected_to_login
  end
  
  def test_view_vial_fails_when_NOT_users_vial
    get :view_vial, { :id => vials(:vial_one).id }, user_session(:jeremy)
    assert_redirected_to :action => "list_vials"
    
    get :view_vial, { :id => 123123 }, user_session(:manage_bench)
    assert_redirected_to :action => "list_vials"
  end
  
  def test_steve_has_no_table_preference
    get :view_vial, { :id => vials(:vial_one).id }, user_session(:manage_bench)
    assert_response :success
    assert_select "em#instruction" do
      assert_select "q"
    end
  end
  
  def test_jeremy_has_table_preferences
    get :view_vial, { :id => vials(:random_vial).id }, user_session(:jeremy)
    assert_response :success
    assert_select "table" do
      assert_select "tr:nth-child(1) th:nth-child(2)", "white"
      assert_select "tr:nth-child(1) th:nth-child(3)", "red"
      assert_select "tr:nth-child(2) th:nth-child(1)", "curly"
      assert_select "tr:nth-child(3) th:nth-child(1)", "straight"
    end
  end
  
  def test_visible_characters_in_select_boxes_for_table
    get :view_vial, {:id => vials(:random_vial).id }, user_session(:jeremy)
    assert_response :success
    assert_select "div#character_cols" do
      assert_select "select[name=character_col]"
      assert_select "option[value=sex]"
      assert_select "option[value=eye_color]"
      assert_select "option[value=wings]"
    end
    assert_select "div#character_rows" do
      assert_select "select[name=character_row]"
      assert_select "option[value=sex]"
      assert_select "option[value=eye_color]"
      assert_select "option[value=wings]"
    end
  end
  
  def test_set_vial_label
    xhr :post, :set_vial_label, { :id => vials(:vial_one).id, :value => '<Bob>' }, user_session(:manage_bench)
    
    assert_response :success
    assert_equal '&lt;Bob&gt;', @response.body
    
    vial = vials(:vial_one)
    vial.reload
    assert_equal '<Bob>', vial.label
  end
  
  def test_set_vial_label_fails_when_NOT_logged_in
    get :set_vial_label, { :id => vials(:vial_one).id, :value => 'Cool!!!!' }
    assert_redirected_to_login
  end
  
  def test_set_as_solution
    vial = vials(:vial_with_many_flies)
    
    xhr :post, :set_as_solution, { :solution => { :number => 1, :vial_id => vial.id } }, user_session(:manage_bench)
    assert_response :success
    
    vial.reload
    assert_not_nil vial.solution
    assert_equal 1, vial.solution.number

    assert_select_rjs "solution_notice", "img[src=/images/star.png]"
    assert_select_rjs "solution_notice", "This vial is now a solution for problem 1."
  end
  
  def test_set_as_solution_resets_problem_of_vial
    vial = vials(:random_vial)
    original_2_count = Solution.find_all_by_number(2).size
    original_9_count = Solution.find_all_by_number(9).size
    
    xhr :post, :set_as_solution, { :solution => { :number => 9, :vial_id => vial.id } }, user_session(:jeremy)
    assert_response :success
    
    vial.reload
    assert_not_nil vial.solution
    assert_equal 9, vial.solution.number
    assert_equal original_2_count - 1, Solution.find_all_by_number(2).size
    assert_equal original_9_count + 1, Solution.find_all_by_number(9).size

    assert_select_rjs "solution_notice", "img[src=/images/star.png]"
    assert_select_rjs "solution_notice", "This vial is now a solution for problem 9."
  end
  
  def test_set_as_solution_replacement_vial_for_problem_which_already_has_a_solution
    original_vial = vials(:random_vial)
    replacement_vial = vials(:destroyable_vial)
    assert_not_nil original_vial.solution
    assert_nil replacement_vial.solution
    
    xhr :post, :set_as_solution, { :solution => { :number => 2, :vial_id => replacement_vial.id } }, user_session(:jeremy)
    assert_response :success
    
    original_vial.reload
    replacement_vial.reload
    assert_nil original_vial.solution
    assert_not_nil replacement_vial.solution
    assert_equal 2, replacement_vial.solution.number

    assert_select_rjs "solution_notice", "img[src=/images/star.png]"
    assert_select_rjs "solution_notice", "This vial is now a solution for problem 2."
  end
  
  def test_set_as_solution_fails_when_NOT_logged_in
    xhr :post, :set_as_solution, {:number => 1, :vial_id => vials(:vial_with_many_flies).id }
    assert_redirected_to_login
  end
  
  def test_update_table
    xhr :post, :update_table, { :vial_id => vials(:vial_one).id, :character_col => "eye_color", 
        :character_row => "sex" }, user_session(:manage_bench)
    assert_response :success
    
    assert_select "table" do
      assert_select "tr:nth-child(1) th:nth-child(2)", "white"
      assert_select "tr:nth-child(1) th:nth-child(3)", "red"
      assert_select "tr:nth-child(2) th:nth-child(1)", "male"
      assert_select "tr:nth-child(3) th:nth-child(1)", "female"
    end
  end
  
  def test_update_table_fails_when_NOT_logged_in
    xhr :post, :update_table, { :vial_id => vials(:vial_one).id, :character_col => "legs", :character_row => "wings" }
    assert_redirected_to_login
  end
  
  def test_update_parent_div
    xhr :post, :update_parent_div, {:id => flies(:fly_dad).id, :sex => "dad" }, user_session(:manage_bench)
    assert_response :success
    
    assert_select "input[type=hidden][value=7]"
    
    xhr :post, :update_parent_div, {:id => flies(:fly_mom).id, :sex => "mom" }, user_session(:manage_bench)
    assert_response :success
    
    assert_select "input[type=hidden][value=6]"
  end
  
  def test_update_parent_div_fails_when_NOT_logged_in
    xhr :post, :update_parent_div, {:id => flies(:fly_mom).id, :sex => "mom" }
    assert_redirected_to_login
  end
  
    def test_delete_vial
    number_of_old_vials =  Vial.find(:all).size
    post :destroy_vial, { :id => vials(:vial_one).id }, user_session(:manage_bench)
    assert logged_in?, "should be logged in"
    assert_nil Vial.find_by_id(vials(:vial_one).id)
    assert_equal number_of_old_vials - 1, Vial.find(:all).size
    assert !flash.empty?
    assert_equal "First vial has been deleted",  flash[:notice]
    assert_response :redirect
    assert_redirected_to :action => "list_vials"
  end
  
  def test_delete_vial_fails_when_NOT_logged_in
    post :destroy_vial, { :id => vials(:vial_one).id }
    assert_not_nil Vial.find_by_id(vials(:vial_one).id)
    assert flash.empty?
    assert_redirected_to_login
    
    post :destroy_vial, { :id => vials(:vial_one).id }, user_session(:manage_student)
    assert_not_nil Vial.find_by_id(vials(:vial_one).id)
    assert_response 401 # access denied
  end
  
  def test_index_page
    get :index, {}, user_session(:manage_bench)
    assert_response :success
    assert_standard_layout
    assert_select "ul:first-of-type" do
      assert_select "li", 7
    end
  end
  
  def test_mate_flies_page
    get :mate_flies, {}, user_session(:manage_bench)
    assert_response :success
    assert_standard_layout
    assert_select "div#vial_selector_1" do
      assert_select "select[name=vial]"
      assert_select "strong", "First Vial:"
      assert_select "input[name=which_vial][value=1]"
      assert_select "img#spinner_1[src^=/images/ajax-loader-red.gif]"
    end
    assert_select "div#vial_selector_2" do
      assert_select "select[name=vial]"
      assert_select "strong", "Second Vial:"
      assert_select "input[name=which_vial][value=2]"
      assert_select "img#spinner_2[src^=/images/ajax-loader-red.gif]"
    end
    assert_select "div.section_header", "First Vial"
    assert_select "div#big-table-1"
    assert_select "div.section_header", "Second Vial"
    assert_select "div#big-table-2"
  end
  
  def test_collect_mate_data
    get :mate_flies, {}, user_session(:manage_bench)
    assert_response :success
    assert_standard_layout
    
    assert_select "form" do
      assert_select "p", "Label for Offspring Vial:"
      assert_select "input"
      assert_select "p", "Number of Desired Flies:"
      assert_select "input"
    end
  end

  def test_show_mateable_flies
    xhr :post, :show_mateable_flies, {:vial => vials(:vial_one) }, user_session(:manage_bench)
    assert_response :success
    assert_select "table" do
      assert_select "th", 32 * 5
      assert_select "td", 32
      assert_select "th", "female", 16
      assert_select "th", "male", 16
      assert_select "th", "red", 16
      assert_select "th", "white", 16
      assert_select "th", "straight", 16
      assert_select "th", "curly", 16
      assert_select "th", "smooth", 16
      assert_select "th", "hairy", 16
      assert_select "th", "short", 16
      assert_select "th", "long", 16
    end
  end
  
  def test_show_mateable_flies_again
    xhr :post, :show_mateable_flies, {:vial => vials(:vial_with_many_flies) }, user_session(:randy)
    assert_response :success
    assert_select "table" do
      assert_select "th", 4 * 2
      assert_select "td", 4
      assert_select "th", "female", 2
      assert_select "th", "male", 2
      assert_select "th", "smooth", 2
      assert_select "th", "hairy", 2
    end
  end
  
  def test_show_mateable_flies_fails_when_NOT_logged_in_as_student
    xhr :post, :show_mateable_flies, {:vial => vials(:vial_one) }
    assert_redirected_to_login
    
    xhr :post, :show_mateable_flies, {:vial => vials(:vial_one) }, user_session(:manage_student)
    assert_response 401 # access denied
  end
  
  def test_list_vials
    get :list_vials, {}, user_session(:manage_bench)
    assert_response :success
    assert_standard_layout
    assert_select "div#list-vials" do
      assert_select "h4", "steve bench"
      assert_select "ul#2" do
        assert_select "li", 5
        assert_select "li#vial_1", "First vial"
        assert_select "li#vial_1 img[src^=/images/star.png]"
        assert_select "li#vial_2", "Empty vial"
        assert_select "li#vial_2 img", false
        assert_select "li#vial_3", "Single fly vial"
        assert_select "li#vial_3 img", false
        assert_select "li#vial_4", "Multiple fly vial"
        assert_select "li#vial_4 img", false
        assert_select "li#vial_5", "Parents vial"
        assert_select "li#vial_5 img[src^=/images/star.png]"
      end
    end
  end
  
  def test_list_vials_lists_only_current_users_vials
    get :list_vials, {}, user_session(:jeremy)
    assert_response :success
    assert_standard_layout
    assert_select "div#list-vials" do
      assert_select "h4", "jeremy bench"
      assert_select "ul#4" do
        assert_select "li", 2
        assert_select "li#vial_6", "Destroyable vial"
        assert_select "li#vial_6 img", false
        assert_select "li#vial_7", "Another vial"
        assert_select "li#vial_7 img[src^=/images/star.png]"
      end
    end
  end
  
  def test_list_vials_fails_when_NOT_logged_in
    get :list_vials
    assert_redirected_to_login
  end
  
  def test_mate_flies
    number_of_old_vials = Vial.find(:all).size
    post :mate_flies, { :vial => { :label => "children vial", :mom_id => "6", :dad_id => "1" }, 
        :number => "8", :rack_id => "2"}, user_session(:manage_bench)
    new_vial = Vial.find_by_label("children vial")
    assert_not_nil new_vial
    assert_equal [:white] * 8, new_vial.flies.map {|fly| fly.phenotype(:eye_color)}
    assert_response :redirect
    assert_redirected_to :action => "view_vial", :id => new_vial.id
    assert_equal 1, new_vial.user_id
    assert_equal number_of_old_vials + 1, Vial.find(:all).size
  end
    
  def test_mate_flies_again  
    post :mate_flies, { :vial => { :label => "children 2", :mom_id => "4", :dad_id => "3" }, 
        :number => "3", :rack_id => "1" }, user_session(:manage_bench)
    new_vial = Vial.find_by_label("children 2")
    assert_not_nil new_vial
    assert_equal [:red] * 3, new_vial.flies.map {|fly| fly.phenotype(:eye_color)}
    assert_response :redirect
    assert_redirected_to :action => "view_vial", :id => new_vial.id
    assert_equal 1, new_vial.user_id
  end
  
  def test_mate_flies_fails_when_NOT_owned_by_current_user
    number_of_old_vials = Vial.find(:all).size
    post :mate_flies, { :vial => { :label => "stolen children", :mom_id => "4", :dad_id => "3" }, 
        :number => "2", :rack_id => "2"  }, user_session(:jeremy)
    assert_nil Vial.find_by_label("stolen children")
    assert_redirected_to :controller => 'bench', :action => 'list_vials'
    assert_equal number_of_old_vials, Vial.find(:all).size
  end
  
  def test_mate_flies_fails_when_NOT_logged_in
    post :mate_flies, { :vial => { :label => "children vial", :mom_id => "6", :dad_id => "1" }, :number => "8", :rack_id => "3"  }
    assert_redirected_to_login
  end
  
  def test_mate_flies_fails_if_number_invalid
    post :mate_flies, { :vial => { :label => "some vial", :mom_id => "6", :dad_id => "1"}, :number => "276" }, user_session(:manage_bench)
    assert !flash.empty?
    assert_equal "The number of flies should be between 0 and 255.",  flash[:error]
  end
  
  def test_preferences_page
    get :preferences, {}, user_session(:manage_bench)
    assert_response :success
    assert_standard_layout
    assert_select "form" do
      assert_select "input#sex[value=visible][checked=checked]"
      assert_select "input#eye_color[value=visible][checked=checked]"
      assert_select "input#wings[value=visible][checked=checked]"
      assert_select "input#legs[value=visible][checked=checked]"
      assert_select "input#antenna[value=visible][checked=checked]"
      assert_select "input[type=checkbox][checked=checked]", 5
    end
  end
  
  def test_preferences_page_again
    get :preferences, {}, user_session(:randy)
    assert_response :success
    assert_standard_layout
    assert_select "form" do
      assert_select "input#sex[value=visible][type=checkbox][checked=checked]"
      assert_select "input#eye_color[value=visible][type=checkbox][checked=checked]", 0
      assert_select "input#wings[value=visible][type=checkbox][checked=checked]", 0
      assert_select "input#legs[value=visible][type=checkbox][checked=checked]"
      assert_select "input#antenna[value=visible][type=checkbox][checked=checked]", 0
      assert_select "input[type=checkbox][checked=checked]", 2
    end
  end
  
  def test_preferences_page_again_with_scenario
    get :preferences, {}, user_session(:jeremy)
    assert_response :success
    assert_standard_layout
    assert_select "form" do
      assert_select "input#sex[value=visible][type=checkbox][checked=checked]"
      assert_select "input#eye_color[value=visible][type=checkbox][checked=checked]"
      assert_select "input#wings[value=visible][type=checkbox][checked=checked]"
      assert_select "input#legs[value=visible][type=checkbox][checked=checked]", 0
      assert_select "input[type=checkbox][checked=checked]", 3
      assert_select "input[type=checkbox]", 4
    end
  end
  
  def test_change_preferences
    assert_equal 0, users(:steve).hidden_characters.size
    post :preferences, {:sex => "visible", :wings => "visible", :antenna => "visible"}, user_session(:steve)
    assert_response :redirect
    assert_redirected_to :controller => 'bench', :action => 'index'
    users(:steve).reload
    assert_equal [:eye_color, :legs], users(:steve).hidden_characters
    assert_equal [:sex, :wings, :antenna], users(:steve).visible_characters
    
    post :preferences, {:sex => "visible", :wings => "visible", :legs => "visible"}, user_session(:steve)
    assert_redirected_to :controller => 'bench', :action => 'index'
    users(:steve).reload
    assert_equal [:eye_color, :antenna], users(:steve).hidden_characters
    assert_equal [:sex, :wings, :legs], users(:steve).visible_characters
  end
  
  def test_change_preferences_fails_when_NOT_logged_in_as_student
    post :preferences, {:sex => "visible", :wings => "visible"}
    assert_redirected_to_login
    
    number_of_old_preferences = CharacterPreference.find(:all)
    post :preferences, {:sex => "visible", :legs => "visible"}, user_session(:manage_student)
    assert_response 401 # access denied
    assert_equal number_of_old_preferences, CharacterPreference.find(:all)
  end
  
  def test_choose_scenario_page
    get :choose_scenario, {}, user_session(:randy)
    assert_response :success
    assert_standard_layout
    assert_select "form" do
      assert_select "select#scenario_id" do
        assert_select "option[value=]", "None"
        assert_select "option[value=1]", "forgetful instructor"
        assert_select "option", 2
      end
    end
  end
  
  def test_choose_scenario
    assert_nil users(:randy).current_scenario
    post :choose_scenario, { :scenario_id => 1 }, user_session(:randy)
    assert_response :redirect
    assert_redirected_to :controller => 'bench', :action => 'index'
    users(:randy).reload
    assert_equal scenarios(:first_scenario), users(:randy).current_scenario
  end
  
  def test_choose_scenario_fails_when_NOT_scenario_for_course
    assert_nil users(:steve).current_scenario
    post :choose_scenario, { :scenario_id => 1 }, user_session(:steve)
    assert_response :redirect
    assert_redirected_to :controller => 'bench', :action => 'index'
    users(:steve).reload
    assert_nil users(:steve).current_scenario
  end
  
  def test_choose_scenario_fails_when_NOT_logged_in_as_student
    post :choose_scenario, { :scenario_id => 1 }
    assert_redirected_to_login
    
    post :choose_scenario, { :scenario_id => 1 }, user_session(:mendel)
    assert_response 401 # access denied
    
    post :choose_scenario, { :scenario_id => 1 }, user_session(:calvin)
    assert_response 401 # access denied
  end
  
  def test_choose_scenario_fails_when_NOT_valid_scenario_id
    old_scenario = users(:steve).current_scenario
    post :choose_scenario, { :scenario_id => 99999999999 }, user_session(:steve)
    assert_response :redirect
    assert_redirected_to :controller => 'bench', :action => 'index' # or something
    assert_equal old_scenario, users(:steve).current_scenario
  end
  
end
