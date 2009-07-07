require File.dirname(__FILE__) + '/../spec_helper'
require 'bench_controller'

# Re-raise errors caught by the controller.
class BenchController; def rescue_action(e) raise e end; end

class BenchControllerTest < ActionController::TestCase

  fixtures :all
  
  def setup
    @controller = BenchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_collect_field_vial_of_four_flies
    number_of_old_vials =  Vial.count
    
    post :collect_field_vial, {
      :vial => {
        :label => "four fly vial",
        :number_of_requested_flies => "4",
        :shelf_id => "2"
      } },
    user_session(:steve)
    
    new_vial = Vial.find_by_label("four fly vial")
    assert_not_nil new_vial
    assert_equal number_of_old_vials + 1, Vial.find(:all).size
    assert_equal 4, new_vial.flies.size
    assert_equal 4, users(:steve).basic_preference.flies_number
    assert_equal 2, new_vial.shelf.id
    assert_equal users(:steve), new_vial.owner
    assert_response :redirect
    assert_redirected_to :action => "view_vial", :id => new_vial.id
  end
  
  def test_collect_field_vial_of_nine_flies
    number_of_old_vials =  Vial.count
    
    post :collect_field_vial, {
      :vial => {
        :label => "nine fly vial",
        :number_of_requested_flies => "9",
        :shelf_id => "2"
      } },
    user_session(:steve)
    
    assert logged_in?, "should be logged in"
    new_vial = Vial.find_by_label("nine fly vial")
    assert_not_nil new_vial
    assert_equal number_of_old_vials + 1, Vial.count
    assert_equal 9, new_vial.flies.size
    assert_equal 9, users(:steve).basic_preference.flies_number
    assert_equal 2, new_vial.shelf.id
    assert_equal users(:steve), new_vial.owner
    assert_response :redirect
    assert_redirected_to :action => "view_vial", :id => new_vial.id
  end
  
  def test_collect_field_vial_fails_when_NOT_logged_in
    assert_no_added_vials do
      post :collect_field_vial, {
          :vial => {
            :label => "anonomous user's vial",
            :number_of_requested_flies => "8",
            :shelf_id => "3" } }
      assert_redirected_to_login
    end
  end
  
  def test_collect_field_vial_fails_if_number_invalid
    assert_no_added_vials do
      post :collect_field_vial, {
        :vial => {
          :label => "some vial",
          :number_of_requested_flies => "581",
          :shelf_id => "2"}
      },
      user_session(:steve)
      
      vial = assigns(:vial)
      assert vial.errors.invalid?(:number_of_requested_flies)
      assert_equal 42, users(:steve).basic_preference.flies_number
    end
  end
  
  def test_collect_field_vial_fails_if_shelf_NOT_owned
    assert_no_added_vials do
      post :collect_field_vial, {
        :vial => {
          :label => "some vial for someone else",
          :number_of_requested_flies => "81",
          :shelf_id => "4"}
      },
      user_session(:steve)
      
      assert_nil Vial.find_by_label("some vial for someone else")
      assert_equal 42, users(:steve).basic_preference.flies_number
    end
  end
  
  def test_collect_field_vial_page
    post :collect_field_vial, {}, user_session(:steve)
    assert_response :success
    
    assert_select "form" do
      assert_select "label", "Label:"
      assert_select "input#vial_label"
      assert_select "label", "Number of flies:"
      assert_select "select#vial_shelf_id"
      assert_select "input#vial_number_of_requested_flies[value=42]"
    end
  end
  
  def test_add_shelf
    number_of_old_shelves =  Shelf.find(:all).size
    post :add_shelf, {
        :shelf => { :label => "super storage unit"} },
        user_session(:steve)
        
    new_shelf = Shelf.find_by_label("super storage unit")
    assert_not_nil new_shelf
    assert_equal users(:steve).current_scenario, new_shelf.scenario
    assert_equal number_of_old_shelves + 1, Shelf.find(:all).size
    assert_equal users(:steve), new_shelf.owner
    assert_response :redirect
    assert_redirected_to :action => "list_vials"
  end
  
  def test_add_shelf_fails_when_NOT_logged_in
    post :add_shelf, { :shelf => { :label => "super duper unit"} }
    assert_redirected_to_login
  end
  
  def test_add_shelf_fails_when_named_trash
    number_of_old_shelves =  Shelf.find(:all).size
    post :add_shelf, {
        :shelf => { :label => "trash"} },
        user_session(:steve)
    assert_equal number_of_old_shelves, Shelf.find(:all).size
    assert_redirected_to :action => "list_vials"
  end
  
  def test_add_shelf_protects_vials
    post :add_shelf, {
      :shelf => {
        :label => "Been caught stealing!",
        :vial_ids => [1, 2, 3, 4, 5, 6, 7]
      }
    }, user_session(:randy)
    
    assert_response :redirect
    assert_redirected_to :action => "list_vials"

    new_shelf = Shelf.find_by_label("Been caught stealing!")
    assert_not_nil new_shelf
    assert_equal users(:randy), new_shelf.owner
    Vial.find([1, 2, 3, 4, 5, 6, 7]).each do |vial|      
      assert_not_equal users(:randy), vial.owner, "should not own vial #{vial.id}"
    end
  end
  
  def test_add_shelf_page
    get :add_shelf, {}, user_session(:steve)
    
    assert_response :success
    
    assert_select "form" do
      assert_select "label", "Label:"
      assert_select "input#shelf_label[size=40]"
    end
  end
  
  def test_move_vial_to_another_shelf
    number_of_old_vials_in_shelf = Shelf.find(1).vials.size
    xhr :post, :move_vial_to_another_shelf, { :id => 5, :vial => {:shelf_id => 1 } }, user_session(:steve)
    assert_equal number_of_old_vials_in_shelf + 1, Shelf.find(1).vials.size
    assert_equal 1, Vial.find(5).shelf_id
    assert_response :success
    assert_select_rjs :replace_html, "move_notice"
    assert_select_rjs "move_notice" do
      assert_select "img[src^=/images/pill_go.png]"
      assert_select "p", "#{Vial.find(5).label} was moved to #{Shelf.find(1).label}."
    end
  end
  
  def test_move_vial_to_another_shelf_fails_when_NOT_logged_in
    post :move_vial_to_another_shelf, { :id => 4, :vial => {:shelf_id => 1 } }
    assert_redirected_to_login
  end
  
  def test_move_vial_to_another_shelf_fails_when_NOT_owner_of_vial
    post :move_vial_to_another_shelf, { :id => 7, :vial => {:shelf_id => 1 } }, user_session(:steve)
    assert_redirected_to :action => "list_vials"
  end
  
  def test_move_vial_to_another_shelf_fails_when_NOT_owner_of_shelf
    post :move_vial_to_another_shelf, { :id => 3, :vial => {:shelf_id => 5 } }, user_session(:steve)
    assert_redirected_to :action => "list_vials"
  end
  
  def test_view_vial_with_a_fly
    vial = vials(:vial_with_a_fly)
    
    get :view_vial, { :id => vial.id }, user_session(:steve)
    
    assert_response :success
    
    assert_select "h1", /Vial #{vial.label}/
    assert_select "span#vial_label_3_in_place_editor", vial.label
    
    assert_select "div#vial-table" do
      assert_select "img[src^=/images/blank_table.png]"
    end
    
    assert_select "form[action=/bench/update_table]" do
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
    end
    
    assert_select "div#parent-info table" do
      assert_select "p", "Parent information is unknown for field vials."
    end
    assert_select "div#vial_maintenance" do
      assert_select "div#solution_notice", ""
      assert_select "form[action=/bench/set_as_solution]" do 
        assert_select "label", "Submit as a solution to Problem #"
        assert_select "select#solution_number" do
          assert_select "option", 10
        end
        assert_select "input[type=hidden][value=3]"
      end
      assert_select "form" do
        assert_select "select#vial_shelf_id" do
          assert_select "option", 2, "steve should have 2 visible shelves for current scenario"
        end
      end
    end
    assert_select "div#move_to_trash" do
      assert_select "img[src^=/images/bin_empty.png]"
      assert_select "a.negative[href^=/bench/destroy_vial?vial_id=3]", /Move to Trash/
    end
  end
  
  def test_view_vial_with_many_flies
    vial = vials(:vial_with_many_flies)
    
    get :view_vial, { :id => vial.id }, user_session(:steve)
    
    assert_response :success
    
    assert_select "h1", /Vial #{vial.label}/
    assert_select "span#vial_label_4_in_place_editor", vial.label
        
    assert_select "div#vial-table" do
      assert_select "img[src^=/images/blank_table.png]"
    end
    
    assert_select "form[action=/bench/update_table]" do
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
    end
    
    assert_select "div#parent-info table" do
      assert_select "p", "Parent information is unknown for field vials."
    end
    assert_select "div#vial_maintenance" do
    assert_select "div#solution_notice", ""
      assert_select "form[action=/bench/set_as_solution]" do 
        assert_select "label", "Submit as a solution to Problem #"
        assert_select "select#solution_number" do
          assert_select "option", 10
        end
        assert_select "input[type=hidden][value=4]"
      end
      assert_select "form" do
        assert_select "select#vial_shelf_id" do
          assert_select "option", 2, "steve should have 2 visible shelves for current scenario"
        end
      end
    end
    assert_select "div#move_to_trash" do
      assert_select "img[src^=/images/bin_empty.png]"
      assert_select "a.negative[href^=/bench/destroy_vial?vial_id=4]", /Move to Trash/
    end
  end
  
  def test_view_vial_one
    vial = vials(:vial_one)
    
    get :view_vial, { :id => vial.id }, user_session(:steve)
    
    assert_response :success
    
    assert_select "h1", /Vial #{vial.label}/
    assert_select "span#vial_label_1_in_place_editor", vial.label
    assert_select "div#vial-table" do
      assert_select "img[src^=/images/blank_table.png]"
    end
    
    assert_select "form[action=/bench/update_table]" do
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
    end
    
    assert_select "div#parent-info table" do
      assert_select "p", "Parent information is unknown for field vials."
    end
    assert_select "div#vial_maintenance" do    
      assert_select "div#solution_notice", "This is a solution to Problem #8."
      assert_select "form[action=/bench/set_as_solution]" do 
        assert_select "label", "Submit as a solution to Problem #"
        assert_select "select#solution_number" do
          assert_select "option", 10
          assert_select "option[value=8][selected=selected]", "8"
        end
        assert_select "input[type=hidden][value=1]"
      end
      assert_select "form" do
        assert_select "select#vial_shelf_id" do
          assert_select "option", 2, "steve should have two visible shelfs for current scenario"
        end
      end
    end
    assert_select "div#move_to_trash" do
      assert_select "img[src^=/images/bin_empty.png]"
      assert_select "a.negative[href^=/bench/destroy_vial?vial_id=1]", /Move to Trash/
    end
  end
  
  def test_view_vial_fails_when_NOT_logged_in
    get :view_vial, { :id => vials(:vial_one).id }
    assert_redirected_to_login
  end
  
  def test_view_vial_fails_when_NOT_users_vial
    get :view_vial, { :id => vials(:vial_one).id }, user_session(:jeremy)
    assert_redirected_to :action => "list_vials"
    
    get :view_vial, { :id => 123123 }, user_session(:steve)
    assert_redirected_to :action => "list_vials"
  end
  
  def test_steve_has_no_table_preference
    get :view_vial, { :id => vials(:vial_one).id }, user_session(:steve)
    assert_response :success
    assert_select "img[src^=/images/blank_table.png]", true, "should have displayed an example image"
  end
  
  def test_jeremy_has_table_preferences
    get :view_vial, { :id => vials(:random_vial).id }, user_session(:jeremy)
    assert_response :success
    assert_select "table" do
      assert_select "tr:nth-child(1) th:nth-child(2)", "beige"
      assert_select "tr:nth-child(1) th:nth-child(3)", "orange"
      assert_select "tr:nth-child(2) th:nth-child(1)", "curly"
      assert_select "tr:nth-child(3) th:nth-child(1)", "straight"
    end
  end
  
  def test_visible_characters_in_select_boxes_for_table
    get :view_vial, {:id => vials(:random_vial).id }, user_session(:jeremy)
    assert_response :success
    assert_select "select[name=character_col]" do
      assert_select "option[value=sex]"
      assert_select "option[value=eye color]"
      assert_select "option[value=wings]"
    end
    assert_select "select[name=character_row]" do
      assert_select "option[value=sex]"
      assert_select "option[value=eye color]"
      assert_select "option[value=wings]"
    end
  end
  
  def test_set_vial_label
    xhr :post, :set_vial_label, { :id => vials(:vial_one).id, :value => '<Bob>' }, user_session(:steve)
    
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
  
  def test_set_vial_label_fails_when_NOT_owned_by_current_user
    xhr :post, :set_vial_label, { :id => vials(:random_vial).id, :value => 'Hi Jeremy! from Steve' }, 
        user_session(:steve)
        
    assert_response 401 # permission denied
    
    vial = vials(:random_vial)
    vial.reload
    assert_equal 'Another vial', vial.label
  end
  
  def test_set_vial_label_restricted_to_xhr_post_only
    assert_xhr_post_only :set_vial_label,
        { :id => vials(:vial_one).id, :value => '<Bob>' }, user_session(:steve)
  end
  
  def test_set_shelf_label
    xhr :post, :set_shelf_label, { :id => shelves(:steve_bench_shelf).id, :value => 'Stock > Bench'}, user_session(:steve)
    
    assert_response :success
    assert_equal 'Stock &gt; Bench', @response.body
    
    shelf = shelves(:steve_bench_shelf)
    shelf.reload
    assert_equal 'Stock > Bench', shelf.label
  end
  
  def test_set_shelf_label_fails_when_NOT_logged_in
    get :set_shelf_label, { :id => shelves(:steve_stock_shelf).id, :value => 'I am not logged in!' }
    assert_redirected_to_login
  end
  
  def test_set_shelf_label_fails_when_NOT_owned_by_current_user
    xhr :post, :set_shelf_label, { :id => shelves(:jeremy_stock_shelf).id, :value => 'Jeremys Solutions'},
        user_session(:steve)
        
    assert_response 401 # permission denied
    
    shelf = shelves(:jeremy_stock_shelf)
    shelf.reload
    assert_equal 'jeremy stock', shelf.label
  end
  
  def test_set_shelf_label_restricted_to_xhr_post_only
    assert_xhr_post_only :set_shelf_label,
        { :id => shelves(:steve_bench_shelf).id, :value => 'Favorite shelf'}, user_session(:steve)
  end
  
  def test_set_shelf_label_to_trash
    xhr :post, :set_shelf_label, { :id => shelves(:steve_bench_shelf).id, :value => 'Trash'}, user_session(:steve)
    
    assert_response :success
    assert_equal 'steve bench', @response.body
    
    shelf = shelves(:steve_bench_shelf)
    shelf.reload
    assert_equal 'steve bench', shelf.label
  end
  
  def test_set_as_solution
    vial = vials(:vial_with_many_flies)
    
    xhr :post, :set_as_solution, { :solution => { :number => 1, :vial_id => vial.id } }, user_session(:steve)
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
    xhr :post, :update_table, { :vial_id => vials(:vial_one).id, :character_col => "eye color", 
      :character_row => "sex" }, user_session(:steve)
    assert_response :success
    
    assert_select "table" do
      assert_select "tr:nth-child(1) th:nth-child(2)", "red"
      assert_select "tr:nth-child(1) th:nth-child(3)", "white"
      assert_select "tr:nth-child(2) th:nth-child(1)", "female"
      assert_select "tr:nth-child(3) th:nth-child(1)", "male"
    end
  end
  
  def test_update_table_fails_when_NOT_logged_in
    xhr :post, :update_table,
        { :vial_id => vials(:vial_one).id, :character_col => "legs",
          :character_row => "wings" }
    assert_redirected_to_login
  end
  
  def test_update_table_fails_when_NOT_owner_of_vial
    xhr :post, :update_table, { :vial_id => vials(:random_vial).id, :character_col => "eye color", 
      :character_row => "sex" }, user_session(:steve)
      
    assert_response 401 # permission denied
  end
  
  def test_update_table_restricted_to_xhr_post_only
    assert_xhr_post_only :update_table,
        { :vial_id => vials(:vial_one).id, :character_col => "eye color", :character_row => "sex" }, 
        user_session(:steve)
  end
  
  def test_delete_vial
    number_of_vials_in_trash = Shelf.find(shelves(:steve_trash_shelf)).vials.size
    
    post :destroy_vial, { :vial_id => vials(:vial_with_a_fly).id, :shelf_id => shelves(:steve_trash_shelf).id }, user_session(:steve)
    assert_redirected_to :action => 'list_vials'
    
    assert_equal number_of_vials_in_trash + 1, Shelf.find(shelves(:steve_trash_shelf)).vials.size
    assert_equal shelves(:steve_trash_shelf).id, Vial.find(vials(:vial_with_a_fly)).shelf_id
  end
  
  def test_delete_solution_vial_fails
    number_of_vials_in_trash = Shelf.find(shelves(:steve_trash_shelf)).vials.size
    
    post :destroy_vial, { :vial_id => vials(:vial_one).id, :shelf_id => shelves(:steve_trash_shelf).id }, user_session(:steve)
    assert_redirected_to :action => 'list_vials'
    
    assert_equal "#{vials(:vial_one).label} cannot be moved to the Trash because it is a solution to problem #{vials(:vial_one).solution.number}.", flash[:notice]
    assert_equal number_of_vials_in_trash, Shelf.find(shelves(:steve_trash_shelf)).vials.size
    assert_not_equal shelves(:steve_trash_shelf).id, Vial.find(vials(:vial_one)).shelf_id
  end
  
  def test_delete_vial_fails_when_NOT_logged_in
    post :destroy_vial, { :vial_id => vials(:vial_one).id, :shelf_id => shelves(:steve_trash_shelf).id }

    assert_redirected_to_login
  end
  
  def test_delete_vial_fails_when_deleted_by_non_owner
    assert_equal users(:steve), vials(:vial_one).owner
    
    post :destroy_vial, { :vial_id => vials(:vial_one).id, :shelf_id => shelves(:steve_trash_shelf).id }, user_session(:jeremy)
    assert_redirected_to :action => "list_vials" 
  end
  
  def test_index_page
    get :index, {}, user_session(:steve)
    
    assert_response :success

    assert_select "h1", "The Bench"
    assert_select "h2", "Fly and Vial Operations"
    assert_select "ul#fly_and_vial_operations" do
      assert_select "li", 3
      assert_select "li a[href=/bench/list_vials]", "List vials"
      assert_select "li a[href=/bench/mate_flies]", "Mate flies"
      assert_select "li a[href=/bench/collect_field_vial]", "Collect a field vial"
    end
    assert_select "h2", "Rack Operations"
    assert_select "ul#shelf_operations" do
      assert_select "li", 1
      assert_select "li a[href=/bench/add_shelf]", "Create a new rack"
    end
    assert_select "h2", "System Operations"
    assert_select "ul#system_operations" do
      assert_select "li", 3
      assert_select "li a[href=/bench/preferences]", "Set your preferences"
      assert_select "li a[href=/bench/choose_scenario]", "Choose a scenario"
      assert_select "li a[href=/users/change_password]", "Change your password"
    end
  end
    
  def test_list_vials
    get :list_vials, {}, user_session(:steve)
    
    assert_response :success
    
    assert_select "h1", "Your Vials"
    assert_select "div#list-vials" do
      assert_select "h2", /Vials on the/
      assert_select "span#shelf_label_2_in_place_editor", "steve bench"
      assert_select "table#shelf_2" do
        assert_select "td", 5
        assert_select "td#vial_1", "First vial"
        assert_select "td#vial_1 img[src^=/images/star.png][title=Solves Problem #8]"
        assert_select "td#vial_1 img", 2
        assert_select "td#vial_2", "Empty vial"
        assert_select "td#vial_2 img", 1
        assert_select "td#vial_3", "Single fly vial"
        assert_select "td#vial_3 img", 1
        assert_select "td#vial_4", "Multiple fly vial"
        assert_select "td#vial_4 img", 1
        assert_select "td#vial_5", "Parents vial"
        assert_select "td#vial_5 img[src^=/images/star.png][title=Solves Problem #1]"
      end
      assert_select "table", 2, "steve should have 2 visible shelves for current scenario"
    end
    assert_select "div#toggle-trash" do
      assert_select "p", "Show/Hide your Trash"
    end
  end
  
  def test_list_vials_lists_only_current_users_vials
    get :list_vials, {}, user_session(:jeremy)
    
    assert_response :success

    assert_select "h1", "Your Vials"
    assert_select "div#list-vials" do
      assert_select "h2", /Vials on the/
      assert_select "span#shelf_label_4_in_place_editor", "jeremy bench"
      assert_select "table#shelf_4" do
        assert_select "td", 2
        assert_select "td#vial_6", "Destroyable vial"
        assert_select "td#vial_6 img", 1
        assert_select "td#vial_7", "Another vial"
        assert_select "td#vial_7 img[src^=/images/star.png]"
        assert_select "td#vial_7 img", 2
      end
    end
  end
  
  def test_list_vials_fails_when_NOT_logged_in
    get :list_vials
    assert_redirected_to_login
  end
  
  def test_collect_mate_data
    get :mate_flies, {}, user_session(:steve)
    
    assert_response :success
    
    assert_select "h2", "Cross the Flies"
    assert_select "form[onsubmit*=Ajax.Request]", 3
    assert_select "form[onsubmit*=disabled = true]"
    assert_select "form[action=/bench/mate_flies]" do
      assert_select "label", "Label for vial of offspring:"
      assert_select "input#vial_label"
      assert_select "label", "Number of offspring:"
      assert_select "input#vial_number_of_requested_flies[value=42]"
      assert_select "label", /^Store in the rack named:/
      assert_select "select#vial_shelf_id" do
        assert_select "option", 2, "steve should have two visible shelves in current scenario"
        assert_select "option", "steve stock"
        assert_select "option", "steve bench"
      end
      assert_select "button[type=submit][value=Cross]", "Cross"
    end
  end
  
  def test_show_mateable_flies_for_first_vial
    xhr :post, :show_mateable_flies,
        { :vial_id => vials(:vial_with_many_flies).id,
          :which_vial => "1"
          },
        user_session(:steve)
        
    assert_response :success
    assert_select_rjs :replace_html, "big-table-1" do
      assert_select "table" do
        assert_select "th", 32 * 5, "should have 2^5 * 5 table headers for 5 characters"
        assert_select "td", 32
        assert_select "th", :text => "female", :count => 16
        assert_select "th", :text => "male", :count => 16
        assert_select "th", :text => "red", :count => 16
        assert_select "th", :text => "white", :count => 16
        assert_select "th", :text => "straight", :count => 16
        assert_select "th", :text => "curly", :count => 16
        assert_select "th", :text => "smooth", :count => 16
        assert_select "th", :text => "hairy", :count => 16
        assert_select "th", :text => "short", :count => 16
        assert_select "th", :text => "long", :count => 16
        assert_select "tr td" do
          assert_select "input[type=radio]", 4, "should be 4 radio buttons"
          assert_select "input[type=radio][value=1]"
          assert_select "input[type=radio][value=3]"
          assert_select "input[type=radio][value=4]"
          assert_select "input[type=radio][value=5]"
        end
      end
    end
  end
  
  def test_show_mateable_flies_for_second_vial
    xhr :post, :show_mateable_flies,
        { :vial_id => vials(:randy_vial).id,
          :which_vial => "2" },
        user_session(:randy)
        
    assert_response :success
    assert_select_rjs :replace_html, "big-table-2" do
      assert_select "table" do
        assert_select "th", 12 * 3
        assert_select "td", 12
        assert_select "th", :text => "female", :count => 6
        assert_select "th", :text => "male", :count => 6
        assert_select "th", :text => "smooth", :count => 6
        assert_select "th", :text => "hairy", :count => 6
        assert_select "th", :text => "no seizure", :count => 4
        assert_select "th", :text => "20% seizure", :count => 4
        assert_select "th", :text => "40% seizure", :count => 4
        assert_select "tr td" do
          assert_select "input[type=radio]", 0, "should be 0 radio buttons"
        end
      end
    end
  end
  
  def test_show_mateable_flies_back_to_instructions_for_first_vial
    xhr :post, :show_mateable_flies,
        { :vial_id => "0",
          :which_vial => "1" },
        user_session(:steve)
        
    assert_response :success
    assert_select_rjs :replace_html, "big-table-1" do
      assert_select "em.instruction", /^Select a vial/
    end
  end
  
  def test_show_mateable_flies_back_to_instructions_for_second_vial
    xhr :post, :show_mateable_flies,
        { :vial_id => "0",
          :which_vial => "2" },
        user_session(:steve)
        
    assert_response :success
    assert_select_rjs :replace_html, "big-table-2" do
      assert_select "em.instruction", /^Select a vial/
    end
  end
  
  def test_show_mateable_flies_fails_for_wrong_users
    good_params = {
        :vial_id => vials(:vial_one).id,
        :which_vial => "1"
      }
      
    xhr :post, :show_mateable_flies, good_params
    assert_redirected_to_login # no user logged in
    
    xhr :post, :show_mateable_flies, good_params, user_session(:manage_student)
    assert_response 401, "should reject non student"

    xhr :post, :show_mateable_flies, good_params, user_session(:randy)
    assert_response 401, "should reject non owner"
  end
  
  def test_show_mateable_flies_rejected_because_of_wrong_http_method
    assert_xhr_post_only :show_mateable_flies,
        { :vial_id => vials(:vial_one).id,
          :which_vial => "1" },
        user_session(:steve)
  end

  def test_update_parent_div_for_dad
    xhr :post, :update_parent_div,
        { :id => flies(:fly_dad).id, :sex => "dad" },
        user_session(:steve)
        
    assert_response :success
    assert_select_rjs :replace_html, "dad" do
      assert_select "input[type=hidden][value=7]"
    end
  end

  def test_update_parent_div_for_mom
    xhr :post, :update_parent_div,
        { :id => flies(:fly_mom).id, :sex => "mom" },
        user_session(:steve)
        
    assert_response :success
    assert_select_rjs :replace_html, "mom" do
      assert_select "input[type=hidden][value=6]"
    end
  end
  
  def test_update_parent_div_fails_when_NOT_logged_in
    xhr :post, :update_parent_div, {:id => flies(:fly_mom).id, :sex => "mom" }
    assert_redirected_to_login
  end
  
  def test_update_parent_div_fails_when_NOT_owner_of_fly
    xhr :post, :update_parent_div,
        { :id => flies(:fly_mom).id, :sex => "mom" },
        user_session(:randy)
    assert_response 401, "should be denied access"    
  end
  
  def test_update_parent_div_fails_fly_does_not_exist
    xhr :post, :update_parent_div,
        { :id => 665, :sex => "mom" },
        user_session(:steve)
    assert_response 401, "should be denied access"    
  end
  
  def test_update_parent_div_restricted_to_xhr_post_only
    assert_xhr_post_only :update_parent_div,
        { :id => flies(:fly_dad).id, :sex => "dad" },
        user_session(:steve)
  end
  
  def test_mate_flies_page
    get :mate_flies, {}, user_session(:steve)
    
    assert_response :success  
    
    assert_nil flash[:error]
    assert_select "div#vial_selector_1" do
      assert_select "h2", "First Vial"
      assert_select "input[name=which_vial][value=1]"
      assert_select "img#spinner_1[src^=/images/green-load.gif]"
      assert_select "select#first_vial_selector[onchange=onsubmit()]" do
        assert_select "option", 6
        assert_select "option[value=0][selected=selected]", ""
        assert_select "option[value=1]", "First vial"
        assert_select "option[value=2]", "Empty vial"
        assert_select "option[value=3]", "Single fly vial"
        assert_select "option[value=4]", "Multiple fly vial"
        assert_select "option[value=5]", "Parents vial"
      end
    end
    assert_select "div#vial_selector_2" do
      assert_select "h2", "Second Vial"
      assert_select "input[name=which_vial][value=2]"
      assert_select "img#spinner_2[src^=/images/green-load.gif]"
      assert_select "select#second_vial_selector[onchange=onsubmit()]" do
        assert_select "option", 6
        assert_select "option[value=0][selected=selected]", ""
        assert_select "option[value=1]", "First vial"
        assert_select "option[value=2]", "Empty vial"
        assert_select "option[value=3]", "Single fly vial"
        assert_select "option[value=4]", "Multiple fly vial"
        assert_select "option[value=5]", "Parents vial"
      end
    end
    assert_select "div#big-table-1"
    assert_select "div#big-table-2"
  end
  
  def test_mate_flies
    number_of_old_vials = Vial.count
    
    xhr :post, :mate_flies,
        { :vial => {
            :label => "children vial",
            :mom_id => "6", :dad_id => "1",
            :shelf_id => "2",
            :number_of_requested_flies => "8"
          } },
        user_session(:steve)
    
    new_vial = Vial.find_by_label("children vial")
    assert_not_nil new_vial
    
    assert_response :success
    assert_rjs_redirect :controller => 'bench',
        :action => 'view_vial', :id => new_vial.id
    
    assert_equal [:white] * 8, phenotypes_of(new_vial, :"eye color")
    assert_equal users(:steve), new_vial.owner
    assert_equal number_of_old_vials + 1, Vial.count
    assert_equal 8, users(:steve).basic_preference.flies_number
  end
  
  def test_mate_flies_again  
    xhr :post, :mate_flies,
        { :vial => {
            :label => "children 2",
            :mom_id => "4", :dad_id => "3",
            :shelf_id => "1",
            :number_of_requested_flies => "3"
          } },
        user_session(:steve)
    
    new_vial = Vial.find_by_label("children 2")
    assert_not_nil new_vial
    
    assert_response :success
    assert_rjs_redirect :controller => 'bench',
        :action => 'view_vial', :id => new_vial.id
    
    assert_equal [:red] * 3, phenotypes_of(new_vial, :"eye color")
    assert_equal users(:steve), new_vial.owner
    assert_equal 3, users(:steve).basic_preference.flies_number
  end
  
  def test_mate_flies_fails_for_some_protocols
    assert_rejected_http_methods [ :xhr_get, :post ], :mate_flies,
        { :vial => {
            :label => "children 2",
            :mom_id => "4", :dad_id => "3",
            :shelf_id => "1",
            :number_of_requested_flies => "3"
        } },
        user_session(:steve)
  end
  
  def test_mate_flies_fails_when_NOT_owned_by_current_user
    assert_no_added_vials do
      xhr :post, :mate_flies, {
          :vial => {
            :label => "stolen children",
            :mom_id => "4", :dad_id => "3", 
            :number_of_requested_flies => "2",
            :shelf_id => "2"
            } }, user_session(:jeremy)
            
      assert_response 401 # access denied!

      assert_nil Vial.find_by_label("stolen children")
      assert_equal 50, users(:jeremy).basic_preference.flies_number
    end
  end
  
  def test_mate_flies_redirects_when_NOT_logged_in
    assert_no_added_vials do
      post :mate_flies, {
          :vial => {
            :label => "children vial",
            :mom_id => "6", :dad_id => "1",
            :number_of_requested_flies => "8", :shelf_id => "3" } }
            
      assert_redirected_to_login
    end
  end
  
  def test_mate_flies_errors_when_NO_parents_are_selected
    assert_no_added_vials do
      xhr :post, :mate_flies, {
          :vial => {
            :label => "children vial",
            :number_of_requested_flies => "8",
            :shelf_id => "2" }
          }, user_session(:steve)
      
      assert_response :success
      assert_select_rjs do
        assert_match(/^Element.update\(\"errors/, @response.body,
            "should update the right element")
        assert_select "li", /dad/i, "should mention missing dad in error"
        assert_select "li", /dad/i, "should mention missing mom in error"
        assert_match(/disabled = false;$/, @response.body,
            "should enable submit button")
      end
      
      assert !assigns(:vial).valid?
      assert assigns(:vial).errors.invalid?(:mom_id)
      assert assigns(:vial).errors.invalid?(:dad_id)
      assert_equal 42, users(:steve).basic_preference.flies_number
    end

    # missing mom xor missing dad yields same result as tested in unit tests
  end
  
  def test_mate_flies_errors_when_number_of_flies_is_invalid
    assert_no_added_vials do
      xhr :post, :mate_flies,
          { :vial => {
              :label => "children vial",
              :dad_id => "1", :mom_id => 6, 
              :shelf_id => "2",
              :number_of_requested_flies => "256" } },
          user_session(:steve)
          
      assert_response :success
      assert_select_rjs do
        assert_match(/^Element.update\(\"errors/, @response.body,
            "should update the right element")
        assert_select "li", /number of requested flies/i,
            "should mention number of flies error"
        assert_match(/disabled = false;$/, @response.body,
            "should enable submit button")
      end
      
      vial = assigns(:vial)
      assert vial.errors.invalid?(:number_of_requested_flies)
      assert_equal 42, users(:steve).basic_preference.flies_number
    end
    
    # other types of numeric failures are tested in the unit tests
  end
      
  def test_preferences_page
    get :preferences, {}, user_session(:steve)

    assert_response :success
    
    assert_select "form" do
      assert_select "input[value=sex][checked=checked]"
      assert_select "input[value=eye color][checked=checked]"
      assert_select "input[value=wings][checked=checked]"
      assert_select "input[value=legs][checked=checked]"
      assert_select "input[value=antenna][checked=checked]"
      assert_select "input[type=checkbox][checked=checked]", 5
    end
  end
  
  def test_preferences_page_again
    get :preferences, {}, user_session(:randy)

    assert_response :success

    assert_select "form" do
      assert_select "input[value=sex][type=checkbox][checked=checked]"
      assert_select "input[value=eye color][type=checkbox][checked=checked]", 0
      assert_select "input[value=wings][type=checkbox][checked=checked]", 0
      assert_select "input[value=legs][type=checkbox][checked=checked]"
      assert_select "input[value=antenna][type=checkbox][checked=checked]", 0
      assert_select "input[value=seizure][type=checkbox][checked=checked]"
      assert_select "input[type=checkbox][checked=checked]", 3
    end
  end
  
  def test_preferences_page_again_with_scenario
    get :preferences, {}, user_session(:jeremy)

    assert_response :success
    
    assert_select "form" do
      assert_select "input[value=sex][type=checkbox][checked=checked]"
      assert_select "input[value=eye color][type=checkbox][checked=checked]"
      assert_select "input[value=wings][type=checkbox][checked=checked]"
      assert_select "input[value=legs][type=checkbox][checked=checked]", 0
      assert_select "input[type=checkbox][checked=checked]", 3
      assert_select "input[type=checkbox]", 4
    end
  end
  
  def test_change_preferences
    assert_equal 1, users(:steve).hidden_characters.size
    post :preferences, {:characters => ["sex", "wings", "antenna"]}, user_session(:steve)
    assert_response :redirect
    assert_redirected_to :controller => 'bench', :action => 'index'
    users(:steve).reload
    assert_equal [ :seizure, :"eye color", :legs], users(:steve).hidden_characters
    assert_equal [:sex, :wings, :antenna], users(:steve).visible_characters
    
    post :preferences, {:characters => ["sex", "wings", "legs"]}, user_session(:steve)
    assert_redirected_to :controller => 'bench', :action => 'index'
    users(:steve).reload
    assert_equal [:seizure, :"eye color", :antenna], users(:steve).hidden_characters
    assert_equal [:sex, :wings, :legs], users(:steve).visible_characters
  end
  
  def test_change_preferences_fails_when_NOT_logged_in_as_student
    post :preferences, {:characters => ["sex", "wings"]}
    assert_redirected_to_login
    
    number_of_old_preferences = CharacterPreference.find(:all)
    post :preferences, {:characters => ["sex", "legs"]}, user_session(:manage_student)
    assert_response 401 # access denied
    assert_equal number_of_old_preferences, CharacterPreference.find(:all)
  end
  
  def test_choose_scenario_page
    get :choose_scenario, {}, user_session(:randy)

    assert_response :success

    assert_select "form" do
      assert_select "select#basic_preference_scenario_id" do
        assert_select "option[value=1]", "forgetful instructor"
        assert_select "option", 3
      end
    end
  end
  
  def test_choose_scenario
    assert_equal scenarios(:everything_included), users(:steve).current_scenario
    assert_equal 0, users(:steve).phenotype_alternates.size
    
    post :choose_scenario, { :basic_preference => { :scenario_id => 2 } }, user_session(:steve)
    
    assert_response :redirect
    assert_redirected_to :controller => 'bench', :action => 'index'
    users(:steve).reload
    assert_equal scenarios(:another_scenario), users(:steve).current_scenario
    assert_equal ["Trash", "steve shelf for party day"],
        users(:steve).current_shelves.map { |r| r.label }.sort
    assert_equal [:"eye color", :"eye color"], 
        users(:steve).phenotype_alternates.map { |pa| pa.affected_character.intern }
    assert_equal [:red, :white].to_set, 
        users(:steve).phenotype_alternates.map { |pa| pa.original_phenotype.intern }.to_set
  end
  
  def test_choose_scenario_without_having_one_should_work
    assert_nil users(:keith).current_scenario
    assert_equal 0, users(:keith).phenotype_alternates.size
    post :choose_scenario, { :basic_preference => { :scenario_id => 1 } }, user_session(:keith)
    assert_response :redirect
    assert_redirected_to :controller => 'bench', :action => 'index'
    users(:keith).reload
    assert_equal scenarios(:first_scenario), users(:keith).current_scenario
    assert_equal ["Default", "Trash"], users(:keith).current_shelves.map { |r| r.label }.sort
  end
  
  def test_choose_scenario_fails_when_NOT_scenario_for_course
    assert_nil users(:keith).current_scenario
    post :choose_scenario, { :basic_preference => { :scenario_id => 3 } }, user_session(:keith)
    assert_response :redirect
    assert_redirected_to :controller => 'bench', :action => 'index'
    users(:keith).reload
    assert_nil users(:keith).current_scenario
    assert users(:keith).shelves.empty?
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
    post :choose_scenario, { :basic_preference => { :scenario_id => 99999999999 } }, user_session(:steve)
    assert_response :redirect
    assert_redirected_to :controller => 'bench', :action => 'index' # or something
    assert_equal old_scenario, users(:steve).current_scenario
  end
  
  def test_students_should_be_redirected_if_they_dont_have_a_scenario
    get :index, {}, user_session(:keith)
    assert_redirected_to :action => "choose_scenario"
    
    get :add_shelf, {}, user_session(:keith)
    assert_redirected_to :action => "choose_scenario"
    
    post :collect_field_vial, {:vial => {:label => "a-vial-of-thunderous-birds",
        :number_of_requested_flies => "7"} }, user_session(:keith)
    assert_redirected_to :action => "choose_scenario"
  end

  #
  # Helpers
  #
  private
  
  def assert_no_added_vials
    original_number_of_vials = Vial.count
    yield
    assert_equal original_number_of_vials, Vial.count, "should have same number of vials"
  end
end
