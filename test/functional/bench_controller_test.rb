require File.dirname(__FILE__) + '/../test_helper'
require 'bench_controller'

# Re-raise errors caught by the controller.
class BenchController; def rescue_action(e) raise e end; end

class BenchControllerTest < Test::Unit::TestCase
  fixtures :flies, :vials
  
  def setup
    @controller = BenchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_actually_collect_field_vial
    number_of_old_vials =  Vial.find(:all).size
    post :collect_field_vial, { :vial => { :label => "something interesting"} }
    new_vial = Vial.find_by_label("something interesting")
    assert_not_nil new_vial
    assert_equal number_of_old_vials + 1, Vial.find(:all).size
    assert_equal 4, new_vial.flies.size
    3.downto(0) do |i|
      assert_equal  new_vial.flies[i].phenotype, [:recessive, :het, :het, :homdom][i]
    end
    
    assert_response :redirect
    assert_redirected_to :action => "view_vial", :id => new_vial.id
  end
  
  def test_choosing_the_size_of_a_vile
    post :collect_field_vial, { :vial => { :label => "test vial with four flies" }, :number => "4" }
    new_vial = Vial.find_by_label("test vial with four flies")
    assert_not_nil new_vial
    assert_equal 4, new_vial.flies.size
    
  end

  def test_collect_field_vial_data
    number_of_old_vials =  Vial.find(:all).size
    post :collect_field_vial
    
    assert_response :success
    assert_standard_layout
    
    assert_select "form" do
      assert_select "p", "Label:"
      assert_select "label"
      #assert_select "p", "Number of Flies:"
      #assert_select "input"
    end
  end
  
  def test_view_vial_with_a_fly
    get :view_vial, :id => vials(:vial_with_a_fly).id 
    assert_response :success
    assert_standard_layout
    assert_select "div.vial-title", vials(:vial_with_a_fly).label
    
    assert_select "table" do
      assert_select "tr:nth-child(2) td.count", "0"
      assert_select "tr:nth-child(3) td.count", "1"
      assert_select "tr:nth-child(4) td.count", "0"
    end
  end
  
  def test_view_vial_with_many_flies
    get :view_vial, :id => vials(:vial_with_many_flies).id
    assert_response :success
    assert_standard_layout
    assert_select "div.vial-title", vials(:vial_with_many_flies).label
    
    assert_select "table" do
      #3.times do |i| assert_select "tr:nth-child(i) td.count", [1,1,1][i] end
      
      assert_select "tr:nth-child(2) td.count", "1"
      assert_select "tr:nth-child(3) td.count", "1"
      assert_select "tr:nth-child(4) td.count", "1"
    end
  end
  
  def test_view_vial_one
    get :view_vial, :id => vials(:vial_one).id
    assert_response :success
    assert_standard_layout
    assert_select "div.vial-title", vials(:vial_one).label
    
    assert_select "table" do
      assert_select "tr:nth-child(2) td.count", "0"
      assert_select "tr:nth-child(3) td.count", "0"
      assert_select "tr:nth-child(4) td.count", "0"
    end
  end
  
end
