require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < ActionController::TestCase
  
  user_fixtures
  
  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_login
    get :login
    assert_response :success
    assert_select "h1", "Log In"
    assert_select "input#user_username[type=text]"
    assert_select "script[type=text/javascript]"
    assert_select "input#user_password[type=password]"
    assert_select "button[type=submit]", /Login/
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
    assert_equal "Invalid login credentials", flash[:error]
    assert !logged_in?
  end
  
  def test_list_users
    get :list_users, {}, user_session(:manage_student)
    assert_response :success
    assert_standard_layout
    assert_select "div#list-users"
    assert_select "ul.list" do
      assert_select "li", 7
      assert_select "li#1", "steve (student)"
      assert_select "li#2", "calvin (admin)"
      assert_select "li#3", "jeremy (student)"
      assert_select "li#4", "randy (student)"
      assert_select "li#5", "mendel (instructor)"
      assert_select "li#6", "darwin (instructor)"
      assert_select "li#7", "keith (student)"
    end
  end
  
  # should list_users only let instructors see the students in their courses?
  
  def test_list_users_fails_when_NOT_logged_in_as_admin
    get :list_users
    assert_redirected_to_login
    
    get :list_users, {}, user_session(:steve)
    assert_response 401, "HTTP response should be access denied"
  end
  
  def test_add_student_form
    get :add_student, {}, user_session(:mendel)
    assert_response :success
    assert_standard_layout
    assert_select "form" do
      assert_select "label[for=username]"
    assert_select "script[type=text/javascript]"
      assert_select "label[for=first_name]"
      assert_select "label[for=last_name]"
      assert_select "label[for=email address]"
      assert_select "label[for=password]"
      assert_select "label[for=password confirmation]"
      assert_select "label[for=course_id]"
      assert_select "label", 7
    end
    assert_select "input[type=text]", 4
  end
  
  def test_add_student
    number_of_old_users =  User.find(:all).size
    post :add_student, {
        :user => {
          :username => "david hansson",
          :email_address => 'hansson@37.signals', 
          :password => 'rails', :password_confirmation => 'rails',
          :first_name => 'David', :last_name => 'Hansson',
          :course_id => 1 }
        }, user_session(:mendel)
        
    assert_redirected_to :action => "list_users"

    new_user = User.find_by_username("david hansson")
    assert_not_nil new_user
    assert_equal number_of_old_users + 1, User.find(:all).size
    assert_equal "David", new_user.first_name
    assert_equal "Hansson", new_user.last_name
    assert_equal "student", new_user.group.name
    assert_equal Course.find(1), new_user.enrolled_in
  end
  
  def test_add_student_fails_when_NOT_logged_in_with_manage_student
    post :add_student, { :user => { :username => "david hansson", :email_address => 'hansson@37.signals', 
        :password => 'rails', :password_confirmation => 'rails', :course_id => 1, 
        :first_name => 'David', :last_name => 'Hansson' } }
    assert_redirected_to_login
    
    post :add_student, { :user => { :username => "david hansson", :email_address => 'hansson@37.signals', 
        :password => 'rails', :password_confirmation => 'rails', :course_id => 1, 
        :first_name => 'David', :last_name => 'Hansson' } }, user_session(:steve)
    assert_nil User.find_by_username("david hansson")
    assert_response 401 # access denied
  end
  
  def test_new_student_doesnt_have_racks
    post :add_student, { :user => { :username => "david hansson", :email_address => 'hansson@37.signals', 
        :password => 'rails', :password_confirmation => 'rails', :course_id => 1, 
        :first_name => 'David', :last_name => 'Hansson' } }, user_session(:manage_student)
    new_student = User.find_by_username("david hansson")
    assert_not_nil new_student
    assert_equal [], new_student.racks
  end
  
  def test_add_instructor_form
    get :add_instructor, {}, user_session(:calvin)
    assert_response :success
    assert_standard_layout
    assert_select "form" do
      assert_select "label", "Username:"
      assert_select "script[type=text/javascript]"
      assert_select "label", "Email Address:"
      assert_select "label", "Password:"
      assert_select "label", "Password Confirmation:"
      assert_select "label", 4
    end
  end
  
  def test_add_instructor
    number_of_old_users =  User.find(:all).size
    post :add_instructor, {
        :user => {
          :username => "a prof",
          :email_address => 'acp@calvin.ude', 
          :password => 'fly', :password_confirmation => 'fly',
          :first_name => 'Isaac', :last_name => 'Newton' } },
        user_session(:calvin)
        
    assert_response :redirect
    assert_redirected_to :action => "list_users"

    new_user = User.find_by_username("a prof")
    assert_not_nil new_user
    assert_equal number_of_old_users + 1, User.find(:all).size
    assert_equal "a prof", new_user.username
    assert_equal "acp@calvin.ude", new_user.email_address
    assert_equal "Isaac", new_user.first_name
    assert_equal "Newton", new_user.last_name
    assert_equal groups(:instructor), new_user.group
  end
  
  def test_add_instructor_fails_when_NOT_logged_as_admin
    post :add_instructor, { :user => { :username => "david hansson", :email_address => 'hansson@37.signals', 
        :password => 'rails', :password_confirmation => 'rails' } }
    assert_redirected_to_login
    
    post :add_instructor, { :user => { :username => "david hansson", :email_address => 'hansson@37.signals', 
        :password => 'rails', :password_confirmation => 'rails' } }, user_session(:steve)
    assert_nil User.find_by_username("david hansson")
    assert_response 401 # access denied
    
    post :add_instructor, { :user => { :username => "monk 1", :email_address => 'monk1@the.church', 
        :password => 'green', :password_confirmation => 'green' } }, user_session(:mendel)
    assert_nil User.find_by_username("monk 1")
    assert_response 401 # access denied
  end
  
  def test_batch_add_students_view
    get :batch_add_students, {}, user_session(:mendel)
    assert_response :success
    assert_standard_layout
    assert_select "form" do
      assert_select "label[for=student_csv]"
      assert_select "textarea#student_csv"
      assert_select "label[for=password]"
      assert_select "input#password"
      assert_select "label[for=course_id]"
      assert_select "select#user_course_id" do
        assert_select "option", 1
      end
      assert_select "label", 3
    end
  end
  
  def test_batch_add_students
    number_of_old_users = User.find(:all).size
    post :batch_add_students, { :student_csv => "Billy, Z., wyz1@calvin.foo", :password => "biolab",
        :course_id => 1 }, user_session(:mendel)
    assert_redirected_to :controller => "lab", :action => "view_course", :id => 1
    assert User.find_by_username("wyz1")
    assert User.find_by_username("wyz1").password_hash == User.hash_password("biolab")
    assert_equal number_of_old_users + 1, User.find(:all).size
    assert_equal flash[:notice], "1 students added!"
  end
  
  def test_batch_add_students_again
    student_csv = %Q{
      last, first, email@web.site,,
      VanderName, John, jov31@calvin.foo
      A, B, C123@somewhere.edu
      another, new, student@calvin.foo
      this one shouldn't count., ,
      , , ,
    }
    number_of_old_users = User.find(:all).size
    post :batch_add_students, { :student_csv => student_csv, :password => "biolab2",
        :course_id => 1 }, user_session(:mendel)
    assert_redirected_to :controller => "lab", :action => "view_course", :id => 1
    
    assert User.find_by_username("email")
    assert User.find_by_username("jov31")
    assert User.find_by_username("C123")
    assert User.find_by_username("student")
    assert User.find_by_username("email").password_hash == User.hash_password("biolab2")
    assert User.find_by_username("jov31").first_name == "John"
    assert User.find_by_username("C123").last_name == "A"
    assert User.find_by_username("student").email_address == "student@calvin.foo"
    assert_equal number_of_old_users + 4, User.find(:all).size
    assert_equal flash[:notice], "4 students added!"
  end
  
  def test_batch_add_students_can_be_used_by_admin
    number_of_old_users = User.find(:all).size
    post :batch_add_students, { :student_csv => "L, F, fml1@c.f\n C, A, abc3@c.f", :password => "themtoo",
        :course_id => 1 }, user_session(:calvin)
    assert_redirected_to :action => "list_users"
    assert User.find_by_username("fml1")
    assert User.find_by_username("abc3")
    assert User.find_by_username("abc3").password_hash == User.hash_password("themtoo")
    assert_equal number_of_old_users + 2, User.find(:all).size
  end
  
  def test_batch_add_students_fails_when_NOT_logged_in_with_manage_student
    number_of_old_users = User.find(:all).size
    post :batch_add_students, { :student_csv => "A., Newt, student@calvin.foo",  :password => "whoami?",
        :course_id => 1 }
    assert_redirected_to_login
    
    post :batch_add_students, { :student_csv => "A., Newt, student@calvin.foo", :password => "hackzor",
        :course_id => 1 }, user_session(:steve)
    assert_nil User.find_by_username("student")
    assert_response 401 # access denied
    assert number_of_old_users == User.find(:all).size
  end
  
  def test_batch_add_students_fails_when_NOT_instructors_course
    number_of_old_users = User.find(:all).size
    post :batch_add_students, { :student_csv => "A., switcher, sea4@calvin.foo", :password => "sandwich",
        :course_id => 1 }, user_session(:darwin)
    assert_nil User.find_by_username("sea4")
    assert_redirected_to :controller => "lab", :action => "view_course", :id => 1
    assert number_of_old_users == User.find(:all).size
  end
  
  def test_delete_user
    number_of_old_users = User.find(:all).size
    assert_not_nil User.find_by_username("steve")
    post :delete_user, { :id => 1 }, user_session(:calvin)
    assert_nil User.find_by_username("steve")
    assert_equal number_of_old_users - 1, User.find(:all).size
    assert_response :redirect
    assert_redirected_to :action => "list_users"
         
    post :delete_user, { :id => 4 }, user_session(:mendel)
    assert_redirected_to :action => "list_users"
    assert_nil User.find_by_id(4) # randy
  end
  
  def test_delete_user_fails_when_NOT_logged_in_as_admin
    assert_not_nil User.find_by_username("steve")
    post :delete_user, { :id => 1 }
    assert_redirected_to_login
    assert_not_nil User.find_by_username("steve")
    
    assert_not_nil User.find_by_username("randy")
    post :delete_user, { :id => 1 }, user_session(:steve)
    assert_not_nil User.find_by_username("randy")
    assert_response 401 # access denied
  end
  
  def test_delete_user_fails_when_NOT_instructors_student
    post :delete_user, { :id => 1 }, user_session(:mendel)
    assert_redirected_to :action => "list_users"
    assert_not_nil User.find_by_id(1) # steve
  end
  
  def test_change_password_form
    get :change_password, { }, user_session(:steve)
    assert_response :success
    assert_standard_layout
    
    assert_select "form" do
      assert_select "label", "Old Password:"
    assert_select "script[type=text/javascript]"
      assert_select "label", "Password:"
      assert_select "label", "Password Confirmation:"
    end
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
    # can't test flash.now[] the same as flash[].
    assert_tag :tag => "div", :child => /Password Changed/
  end
  
  def test_change_password_fails_with_WRONG_old_password
    steve = users(:steve)
    post :change_password, { :user => { :password => 'rails', :password_confirmation => 'rails' }, 
        :old_password => "not_steve_password" }, user_session(:steve)
    assert_response :success
    assert_standard_layout
    steve.reload
    assert_equal User.hash_password("steve_password"), steve.password_hash
    assert_tag :tag => "div", :child => /Try Again/
  end
  
  def test_change_password_fails_with_MISMATCHED_confirmation
    calvin = users(:calvin)
    post :change_password, { :user => { :password => 'rails', :password_confirmation => 'trains' }, 
        :old_password => "calvin_password" }, user_session(:manage_student)
    assert_response :success
    assert_standard_layout
    calvin.reload
    assert_equal User.hash_password("calvin_password"), calvin.password_hash
    assert_tag :tag => "div", :child => /Try Again/
  end
  
  def test_change_password_fails_when_NOT_logged_in
    post :change_password, { :user => { :password => 'buddy', :password_confirmation => 'buddy' }, 
        :old_password => "lab141" }
    assert_redirected_to_login
  end
  
  def test_change_student_password_form
    get :change_student_password, { }, user_session(:calvin)
    assert_response :success
    assert_standard_layout
    assert_select "form" do
      assert_select "div#students_select", "Student: steve\njeremy\nrandy\nkeith"
      assert_select "label", "Password:"
      assert_select "label", "Password Confirmation:"
    end
  end
  
  def test_change_student_password_form_as_instructor
    get :change_student_password, { }, user_session(:mendel)
    assert_response :success
    assert_standard_layout
    assert_select "form" do
      assert_select "div#students_select", "Student: jeremy\nrandy\nkeith", "shouldn't have steve"
      assert_select "label", "Password:"
      assert_select "label", "Password Confirmation:"
    end
  end
  
  def test_change_student_password
    steve = users(:steve)
    assert_equal User.hash_password("steve_password"), steve.password_hash
    post :change_student_password, { :user => { :password => 'steve_m', 
        :password_confirmation => 'steve_m' }, :student_id => 1 }, user_session(:calvin)
    assert_response :success
    assert_standard_layout
    steve.reload
    assert_equal User.hash_password('steve_m'), steve.password_hash
    assert_equal "Password Changed", flash[:notice]
  end
  
  def test_change_student_password_fails_with_mismatched_confirmation
    steve = users(:steve)
    post :change_student_password, { :user => { :password => 'buffalo', 
        :password_confirmation => 'prairie cow' }, :student_id => 1 }, user_session(:calvin)
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
        :password_confirmation => 'steve_m' }, :student_id => 1 },
        user_session(:jeremy)
    assert_response 401, "access should be denied"
    steve.reload
    assert_equal User.hash_password('steve_password'), steve.password_hash
  end
  
  def test_change_student_password_fails_when_NOT_instructors_student
    old_password_hash = User.find_by_id(3).password_hash
    post :change_student_password, { :user => { :password => 'ninja', 
        :password_confirmation => 'ninja' }, :student_id => 3 },
        user_session(:darwin)
    assert_equal "Try Again", flash[:notice]
    assert_equal old_password_hash, User.find_by_id(3).password_hash
  end
  
  def test_change_student_password_fails_when_NOT_valid_student_id
    post :change_student_password, { :user => { :password => 'samurai', 
        :password_confirmation => 'samurai' }, :student_id => 3000 },
        user_session(:darwin)
    assert_equal "Try Again", flash[:notice]
  end
  
  def test_index
    post :index, {}, user_session(:calvin)
    assert_response :success
    assert_select "ul.list" do
      assert_select "li", 6
    end
  end
  
  def test_index_fails_when_NOT_logged_in_as_admin
    post :index
    assert_redirected_to_login
    
    post :index, {}, user_session(:steve)
    assert_response 401 # access denied
    
    post :index, {}, user_session(:mendel)
    assert_response 401 # access denied
  end
  
  def test_redirect_user
    get :redirect_user, {}, user_session(:steve)
    assert_redirected_to :controller => "bench", :action => "index"
    
    get :redirect_user, {}, user_session(:calvin)
    assert_redirected_to :controller => "users", :action => "index"
    
    get :redirect_user, {}, user_session(:mendel)
    assert_redirected_to :controller => "lab", :action => "index"
  end
  
  def test_redirect_user_when_NOT_logged_in
    get :redirect_user
    assert_redirected_to_login
  end
  
end
