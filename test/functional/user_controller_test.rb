require File.dirname(__FILE__) + '/../test_helper'
require 'user_controller'

# Re-raise errors caught by the controller.
class UserController; def rescue_action(e) raise e end; end

class UserControllerTest < Test::Unit::TestCase

  fixtures :users
  
  def setup
    @controller = UserController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_login
    get :login
    assert_response :success
    assert flash.empty?
    assert_select "h1", "Log In"
    assert_select "input#user_username[type=text]"
    assert_select "input#user_password[type=password]"
    assert_select "input[type=submit]"
  end
  
  def test_login_for_real
    post :login, :user => { :username => 'steve', :password => 'steve_password' }

    assert flash.empty?
    assert_redirected_to :controller => 'bench', :action => 'index'
  end
    
end
