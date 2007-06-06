require File.dirname(__FILE__) + '/../test_helper'
require 'bench_controller'

# Re-raise errors caught by the controller.
class BenchController; def rescue_action(e) raise e end; end

class BenchControllerTest < Test::Unit::TestCase
  fixtures :flies, :vials, :genotypes
  
  def setup
    @controller = BenchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_collect_field_vial_of_four_flies
    number_of_old_vials =  Vial.find(:all).size
    post :collect_field_vial, { :vial => { :label => "four fly vial"}, :number => "4" }
    new_vial = Vial.find_by_label("four fly vial")
    assert_not_nil new_vial
    assert_equal number_of_old_vials + 1, Vial.find(:all).size
    assert_equal 4, new_vial.flies.size
    assert_response :redirect
    assert_redirected_to :action => "view_vial", :id => new_vial.id
  end
  
  def test_collect_field_vial_of_nine_flies
    number_of_old_vials =  Vial.find(:all).size
    post :collect_field_vial, { :vial => { :label => "nine fly vial" }, :number => "9" }
    new_vial = Vial.find_by_label("nine fly vial")
    assert_not_nil new_vial
    assert_equal number_of_old_vials + 1, Vial.find(:all).size
    assert_equal 9, new_vial.flies.size
    assert_response :redirect
    assert_redirected_to :action => "view_vial", :id => new_vial.id
  end

  def test_collect_field_vial_data
    number_of_old_vials =  Vial.find(:all).size
    post :collect_field_vial
    
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
    get :view_vial, :id => vials(:vial_with_a_fly).id 
    assert_response :success
    assert_standard_layout
    assert_select "span#vial_label_3_in_place_editor", vials(:vial_with_a_fly).label
    
    assert_select "table" do
      assert_select "tr:nth-child(2) td.count", "1"
      assert_select "tr:nth-child(2) td.count:nth-child(3)", "0"
      assert_select "tr:nth-child(3) td.count", "0"
      assert_select "tr:nth-child(3) td.count:nth-child(3)", "0"
    end
    assert_select "div#parent-info"
    assert_select "div#parent-info table" do
      assert_select "p", "No parents!"
    end
  end
  
  def test_view_vial_with_many_flies
    get :view_vial, :id => vials(:vial_with_many_flies).id
    assert_response :success
    assert_standard_layout
    assert_select "span#vial_label_4_in_place_editor", vials(:vial_with_many_flies).label
    
    assert_select "table" do
      assert_select "tr:nth-child(2) td.count", "1"
      assert_select "tr:nth-child(2) td.count:nth-child(3)", "1"
      assert_select "tr:nth-child(3) td.count", "2"
      assert_select "tr:nth-child(3) td.count:nth-child(3)", "0"
    end
    assert_select "div#parent-info"
    assert_select "div#parent-info table" do
      assert_select "p", "No parents!"
    end
  end
  
  def test_view_vial_one
    get :view_vial, :id => vials(:vial_one).id
    assert_response :success
    assert_standard_layout
    assert_select "span#vial_label_1_in_place_editor", vials(:vial_one).label
    
    assert_select "table" do
      assert_select "tr:nth-child(2) td.count", "0"
      assert_select "tr:nth-child(2) td.count:nth-child(3)", "0"
      assert_select "tr:nth-child(3) td.count", "0"
      assert_select "tr:nth-child(3) td.count:nth-child(3)", "0"
    end
    assert_select "div#parent-info"
    assert_select "div#parent-info table" do
      assert_select "p", "No parents!"
    end
  end
  
  def test_set_vial_label
    xhr :post, :set_vial_label, { :id => vials(:vial_one).id, :value => '<Bob>' }
    
    assert_response :success
    assert_equal '&lt;Bob&gt;', @response.body
    
    vial = vials(:vial_one)
    vial.reload
    assert_equal '<Bob>', vial.label
  end
  
  def test_list_vials
    get :list_vials
    assert_response :success
    assert_standard_layout
    assert_select "div#list-vials"
    
    assert_select "ul" do
      assert_select "li#1", "First vial"
      assert_select "li#4", "Multiple fly vial"
      assert_select "li#2", "Empty vial"
    end
  end
  
  def test_view_individual_fly
    get :view_fly, :id => flies(:bob).id
    assert_select "ul" do
      assert_select "li", 3
      assert_select "li", "Gender: female"
      assert_select "li", "Eye color: red"
      assert_select "li", "Source vial: Multiple fly vial"
    end
  end
  
  def test_mate_flies
    post :mate_flies, { :vial => { :label => "children vial", :mom_id => "6", :dad_id => "1" }, :number => "8" }
    new_vial = Vial.find_by_label("children vial")
    assert_not_nil new_vial
    assert_equal [:white] * 8, new_vial.flies.map {|fly| fly.phenotype(:eye_color)}.sort_by { |p| p.to_s }
    assert_response :redirect
    assert_redirected_to :action => "view_vial", :id => new_vial.id
    
    post :mate_flies, { :vial => { :label => "children 2", :mom_id => "4", :dad_id => "3" }, :number => "3" }
    new_vial = Vial.find_by_label("children 2")
    assert_not_nil new_vial
    assert_equal [:red] * 3, new_vial.flies.map {|fly| fly.phenotype(:eye_color)}.sort_by { |p| p.to_s }
    assert_response :redirect
    assert_redirected_to :action => "view_vial", :id => new_vial.id
  end
  
end
