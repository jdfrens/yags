require File.dirname(__FILE__) + '/../test_helper'
require 'bench_controller'

# Re-raise errors caught by the controller.
class BenchController; def rescue_action(e) raise e end; end

class BenchControllerTest < Test::Unit::TestCase
  fixtures :flies, :vials, :genotypes
  user_fixtures
  
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

  def test_collect_field_vial_data
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
  
  def test_view_vial_with_a_fly
    get :view_vial, { :id => vials(:vial_with_a_fly).id }, user_session(:manage_bench)
    assert_response :success
    assert_standard_layout
    assert_select "span#vial_label_3_in_place_editor", vials(:vial_with_a_fly).label
        
    assert_select "div#vial-table"
    assert_select "div#parent-info"
    assert_select "div#parent-info table" do
      assert_select "p", "No parents!"
    end
  end
  
  def test_view_vial_with_many_flies
    get :view_vial, { :id => vials(:vial_with_many_flies).id }, user_session(:manage_bench)
    assert_response :success
    assert_standard_layout
    assert_select "span#vial_label_4_in_place_editor", vials(:vial_with_many_flies).label
    
    assert_select "div#vial-table"
    assert_select "div#parent-info"
    assert_select "div#parent-info table" do
      assert_select "p", "No parents!"
    end
  end
  
  def test_view_vial_one
    get :view_vial, { :id => vials(:vial_one).id }, user_session(:manage_bench)
    assert_response :success
    assert_standard_layout
    assert_select "span#vial_label_1_in_place_editor", vials(:vial_one).label

    assert_select "div#vial-table"
    assert_select "div#parent-info"
    assert_select "div#parent-info table" do
      assert_select "p", "No parents!"
    end
  end
  
  def test_view_vial_fails_when_NOT_logged_in
    get :view_vial, { :id => vials(:vial_one).id }
    assert_redirected_to_login
  end
  
  def test_view_vial_fails_when_NOT_users_vial
    get :view_vial, { :id => vials(:vial_one).id }, user_session(:manage_bench_as_frens)
    assert_response :redirect
    assert_redirected_to :action => "list_vials"
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
  
  def test_update_table
    xhr :post, :update_table, { :vial_id => vials(:vial_one).id, :character_col => "eye_color", 
        :character_row => "gender" }, user_session(:manage_bench)
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
  
  def test_index_page
    get :index, {}, user_session(:manage_bench)
    assert_response :success
    assert_standard_layout
    assert_select "p", "Welcome #{users(:steve).username}"
    assert_select "ul:first-of-type" do
      assert_select "li", 3
    end
  end
  
  def test_mate_flies_page
    get :mate_flies, {}, user_session(:manage_bench)
    assert_response :success
    assert_standard_layout
    assert_select "div#first-vial" do
      assert_select "select[name=vial]"
      assert_select "input[name=which_vial][value=1]"
    end
    assert_select "div#second-vial" do
      assert_select "select[name=vial]"
      assert_select "input[name=which_vial][value=2]"
    end
    assert_select "div#big-table-1"
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
    assert_select "table"
    xhr :post, :show_mateable_flies, {:vial => vials(:vial_with_many_flies) }
    assert_response :success
    assert_select "table"
  end
  
  def test_show_mateable_flies_fails_when_NOT_logged_in
    xhr :post, :show_mateable_flies, {:vial => vials(:vial_one) }
    assert_redirected_to_login
  end
  
  def test_list_vials
    get :list_vials, {}, user_session(:manage_bench)
    assert_response :success
    assert_standard_layout
    assert_select "div#list-vials" do
      assert_select "ul" do
        assert_select "li", 5
        assert_select "li#1", "First vial"
        assert_select "li#2", "Empty vial"
        assert_select "li#3", "Single fly vial"
        assert_select "li#4", "Multiple fly vial"
        assert_select "li#5", "Parents vial"
      end
    end
  end
  
  def test_list_vials_lists_only_current_users_vials
    get :list_vials, {}, user_session(:manage_bench_as_frens)
    assert_response :success
    assert_standard_layout
    assert_select "div#list-vials" do
      assert_select "ul" do
        assert_select "li", 2
        assert_select "li#6", "Destroyable vial"
        assert_select "li#7", "Another vial"
      end
    end
  end
  
  def test_list_vials_fails_when_NOT_logged_in
    get :list_vials
    assert_redirected_to_login
  end
  
  def test_view_individual_fly
    get :view_fly, { :id => flies(:bob).id }, user_session(:manage_bench)
    assert_select "ul" do
      assert_select "li", 3
      assert_select "li", "Gender: female"
      assert_select "li", "Eye color: red"
      assert_select "li", "Source vial: Multiple fly vial"
    end
  end
  
  def test_mate_flies
    number_of_old_vials = Vial.find(:all).size
    post :mate_flies, { :vial => { :label => "children vial", :mom_id => "6", :dad_id => "1" }, 
        :number => "8" }, user_session(:manage_bench)
    new_vial = Vial.find_by_label("children vial")
    assert_not_nil new_vial
    assert_equal [:white] * 8, new_vial.flies.map {|fly| fly.phenotype(:eye_color)}.sort_by { |p| p.to_s }
    assert_response :redirect
    assert_redirected_to :action => "view_vial", :id => new_vial.id
    assert_equal 1, new_vial.user_id
    assert_equal number_of_old_vials + 1, Vial.find(:all).size
  end
    
  def test_mate_flies_again  
    post :mate_flies, { :vial => { :label => "children 2", :mom_id => "4", :dad_id => "3" }, 
        :number => "3" }, user_session(:manage_bench)
    new_vial = Vial.find_by_label("children 2")
    assert_not_nil new_vial
    assert_equal [:red] * 3, new_vial.flies.map {|fly| fly.phenotype(:eye_color)}.sort_by { |p| p.to_s }
    assert_response :redirect
    assert_redirected_to :action => "view_vial", :id => new_vial.id
    assert_equal 1, new_vial.user_id
  end
  
  def test_mate_flies_fails_when_NOT_owned_by_current_user
    number_of_old_vials = Vial.find(:all).size
    post :mate_flies, { :vial => { :label => "stolen children", :mom_id => "4", :dad_id => "3" }, 
        :number => "2" }, user_session(:manage_bench_as_frens)
    assert_nil Vial.find_by_label("stolen children")
    assert_redirected_to :controller => 'bench', :action => 'list_vials'
    assert_equal number_of_old_vials, Vial.find(:all).size
  end
  
  def test_mate_flies_fails_when_NOT_logged_in
    post :mate_flies, { :vial => { :label => "children vial", :mom_id => "6", :dad_id => "1" }, 
        :number => "8" }
    assert_redirected_to_login
  end
  
end
