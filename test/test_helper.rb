ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...
  
  def self.user_fixtures
    fixtures :users, :groups, :privileges, :groups_privileges
  end
  
  # eh, i think this might make our lives a bit easier
  def self.all_fixtures
    fixtures :users, :groups, :privileges, :groups_privileges, 
        :flies, :vials, :genotypes, :basic_preferences, :character_preferences, 
        :racks, :courses, :solutions
  end
  
  def assert_standard_layout
    assert_select "h1", "YAGS"
    assert_select "div#session-info" do
      if logged_in?
        assert_select "a[href=/users/logout]", /logout/i
      else
        assert_select "a[href=/users/login]", /login/i
      end
    end
    assert_select "a[href=/]", /home page/i
    assert_select "a[href=/bench]", /bench/i if logged_in?
  end
  
  def assert_redirected_to_login
    assert_redirected_to :controller => 'users', :action => 'login'
  end
    
  def logged_in?
    session[:current_user_id] != nil
  end
  
  def user_session(privilege)
    case privilege
    when :manage_bench
      { :current_user_id => 1 }
    when :steve
      { :current_user_id => 1 }
    when :manage_student
      { :current_user_id => 2 }
    when :manage_bench_as_frens
      { :current_user_id => 3 }
    when :pruim
      { :current_user_id => 4 }
    when :mendel
      { :current_user_id => 5 }
    when :darwin
      { :current_user_id => 6 }
    when :calvin
      { :current_user_id => 2 }
    else
      {}
    end
  end
  
  def assert_equal_set(expected, actual, message=nil)
    assert_equal expected.to_set, actual.to_set, message
  end
  
end
