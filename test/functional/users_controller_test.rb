require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  
  user_fixtures
  
  def setup
    @controller = UsersController.new
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
    assert_redirected_to :controller => 'users', :action => 'redirect_user'
    assert logged_in?
    
    post :login, :user => { :username => 'calvin', :password => 'calvin_password' }
    assert flash.empty?
    assert_redirected_to :controller => 'users', :action => 'redirect_user'
    assert logged_in?
  end
  
  def test_wrong_password
    post :login, :user => { :username => 'steve', :password => 'not_steve_password' }
    assert flash.empty?
    assert !logged_in?
  end
  
  def test_list_users
    get :list_users, {}, user_session(:manage_student)
    assert_response :success
    assert_standard_layout
    assert_select "div#list-users"
    assert_select "ul" do
      assert_select "li", 3
      assert_select "li#1", "steve (student) [delete]"
      assert_select "li#2", "calvin (admin) [delete]"
      assert_select "li#3", "jdfrens (student) [delete]"
    end
  end
  
  def test_list_users_fails_when_NOT_logged_in_as_admin
    get :list_users
    assert_redirected_to_login
    
    get :list_users, {}, user_session(:manage_bench)
    assert_response 401 # access denied
  end
  
  def test_add_student_form
    post :add_student, {}, user_session(:manage_student)
    assert_response :success
    assert_standard_layout
    assert_select "form" do
      assert_select "p", "Username:"
      assert_select "p", "Email Address:"
      assert_select "p", "Password:"
      assert_select "p", "Password Confirmation:"
      assert_select "label", 4
    end
  end
  
  def test_add_student
    number_of_old_users =  User.find(:all).size
    post :add_student, { :user => { :username => "david hansson", :email_address => 'hansson@37.signals', 
        :password => 'rails', :password_confirmation => 'rails' } }, user_session(:manage_student)
    new_user = User.find_by_username("david hansson")
    assert_not_nil new_user
    assert_equal number_of_old_users + 1, User.find(:all).size
    assert_equal "student", new_user.group.name
    assert_response :redirect
    assert_redirected_to :action => "list_users"
  end
  
  def test_add_student_fails_when_NOT_logged_in_as_admin
    post :add_student, { :user => { :username => "david hansson", :email_address => 'hansson@37.signals', 
        :password => 'rails', :password_confirmation => 'rails' } }
    assert_redirected_to_login
    
    post :add_student, { :user => { :username => "david hansson", :email_address => 'hansson@37.signals', 
        :password => 'rails', :password_confirmation => 'rails' } }, user_session(:manage_bench)
    assert_nil User.find_by_username("david hansson")
    assert_response 401 # access denied
  end
  
  def test_delete_user
    number_of_old_users = User.find(:all).size
    assert_not_nil User.find_by_username("steve")
    post :delete_user, { :id => 1 }, user_session(:manage_student)
    assert_nil User.find_by_username("steve")
    assert_equal number_of_old_users - 1, User.find(:all).size
    assert_response :redirect
    assert_redirected_to :action => "list_users"
  end
  
  def test_delete_user_fails_when_NOT_logged_in_as_admin
    assert_not_nil User.find_by_username("steve")
    post :delete_user, { :id => 1 }
    assert_redirected_to_login
    
    assert_not_nil User.find_by_username("steve")
    post :delete_user, { :id => 1 }, user_session(:manage_bench)
    assert_not_nil User.find_by_username("steve")
    assert_response 401 # access denied
  end
  
  def test_change_password
    steve = users(:steve)
    assert_equal User.hash_password("steve_password"), steve.password_hash
    post :change_password, { :user => { :password => 'steve_m', :password_confirmation => 'steve_m' },
        :old_password => "steve_password" }, user_session(:steve)
    assert_response :success
    assert_standard_layout
    steve.reload
    assert_equal User.hash_password('steve_m'), steve.password_hash
    assert_equal "Password Changed", flash[:notice]
  end
  
  def test_change_password_fails_with_wrong_old_password
    steve = users(:steve)
    post :change_password, { :user => { :password => 'rails', :password_confirmation => 'rails' }, 
        :old_password => "not_steve_password" }, user_session(:steve)
    assert_response :success
    assert_standard_layout
    steve.reload
    assert_equal User.hash_password("steve_password"), steve.password_hash
    assert_equal "Try Again", flash[:notice]
  end
  
  def test_change_password_fails_with_mismatched_confirmation
    calvin = users(:calvin)
    post :change_password, { :user => { :password => 'rails', :password_confirmation => 'trains' }, 
        :old_password => "calvin_password" }, user_session(:manage_student)
    assert_response :success
    assert_standard_layout
    calvin.reload
    assert_equal User.hash_password("calvin_password"), calvin.password_hash
    assert_equal "Try Again", flash[:notice]
  end
  
  def test_change_password_fails_when_NOT_logged_in
    post :change_password, { :user => { :password => 'buddy', :password_confirmation => 'buddy' }, 
        :old_password => "lab141" }
    assert_redirected_to_login
  end
  
  def test_change_password_form
    get :change_password, { }, user_session(:manage_bench)
    assert_response :success
    assert_standard_layout
    
    assert_select "form" do
      assert_select "p", "Old Password:"
      assert_select "p", "Password:"
      assert_select "p", "Password Confirmation:"
    end
  end
  
  def test_change_student_password
    steve = users(:steve)
    assert_equal User.hash_password("steve_password"), steve.password_hash
    post :change_student_password, { :user => { :password => 'steve_m', 
        :password_confirmation => 'steve_m' }, :student_id => 1 }, user_session(:manage_student)
    assert_response :success
    assert_standard_layout
    steve.reload
    assert_equal User.hash_password('steve_m'), steve.password_hash
    assert_equal "Password Changed", flash[:notice]
  end
  
  def test_change_student_password_fails_with_mismatched_confirmation
    steve = users(:steve)
    post :change_student_password, { :user => { :password => 'buffalo', 
        :password_confirmation => 'prairie cow' }, :student_id => 1 }, user_session(:manage_student)
    assert_response :success
    assert_standard_layout
    steve.reload
    assert_equal User.hash_password("steve_password"), steve.password_hash
    assert_equal "Try Again", flash[:notice]
  end
  
  def test_change_student_password_fails_when_NOT_logged_in_as_admin
    steve = users(:steve)
    assert_equal User.hash_password("steve_password"), steve.password_hash
    post :change_student_password, { :user => { :password => 'steve_m', 
        :password_confirmation => 'steve_m' }, :student_id => 1 }
    assert_redirected_to_login
    steve.reload
    assert_equal User.hash_password('steve_password'), steve.password_hash
    
    steve = users(:steve)
    assert_equal User.hash_password("steve_password"), steve.password_hash
    post :change_student_password, { :user => { :password => 'steve_m', 
        :password_confirmation => 'steve_m' }, :student_id => 1 }, user_session(:manage_bench_as_frens)
    assert_response 401 # access denied
    steve.reload
    assert_equal User.hash_password('steve_password'), steve.password_hash
  end
  
  def test_change_student_password_form
    get :change_student_password, { }, user_session(:manage_student)
    assert_response :success
    assert_standard_layout
    
    assert_select "form" do
      assert_select "div#students_select", "Student:steve\njdfrens"
      assert_select "p", "Password:"
      assert_select "p", "Password Confirmation:"
    end
  end
  
  def test_index
    post :index, {}, user_session(:manage_student)
    assert_response :success
    assert_select "ul" do
      assert_select "li", 4
    end
  end
  
  def test_index_fails_when_NOT_logged_in_as_admin
    post :index
    assert_redirected_to_login
    
    post :index, {}, user_session(:manage_bench)
    assert_response 401 # access denied
  end
  
  def test_redirect_user
    get :redirect_user, {}, user_session(:manage_bench)
    assert_redirected_to :controller => "bench", :action => "index"
    
    get :redirect_user, {}, user_session(:manage_student)
    assert_redirected_to :controller => "users", :action => "index"
  end
  
  def test_redirect_user_when_NOT_logged_in
    get :redirect_user
    assert_redirected_to_login
  end
  
end
