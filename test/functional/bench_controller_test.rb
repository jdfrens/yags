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
  
  def test_collect_field_vial
    number_of_old_vials =  Vial.find(:all).size
    post :collect_field_vial
    
    new_vial = Vial.find_by_label("field vial")
    assert_not_nil new_vial
    assert_equal number_of_old_vials + 1, Vial.find(:all).size
    assert_equal 4, new_vial.flies.size
    3.downto(0) do |i|
      assert_equal  new_vial.flies[i].phenotype, [:recessive, :het, :het, :homdom][i]
    end
    
    assert_response :redirect
    assert_redirected_to :action => "view_vial", :id => new_vial.id
  end
  
  def test_view_vial
    
  end
end
