require File.dirname(__FILE__) + '/../test_helper'
require 'lab_controller'

# Re-raise errors caught by the controller.
class LabController; def rescue_action(e) raise e end; end

class LabControllerTest < Test::Unit::TestCase
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
      assert_select "li", 4
    end
  end
  
  def test_index_fails_when_NOT_logged_in_as_instructor
    post :index
    assert_redirected_to_login
    
    post :index, {}, user_session(:calvin)
    assert_response 401 # access denied
  end
  
end
