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
  
  def self.all_fixtures
    fixtures :users, :groups, :privileges, :groups_privileges, 
        :flies, :vials, :genotypes, :basic_preferences, :character_preferences, 
        :racks, :courses, :solutions, :scenarios, :scenario_preferences,
        :courses_scenarios, :phenotype_alternates, :renamed_characters
  end
  
  def assert_standard_layout
    assert_select "div.bar" do
      assert_select "h1", "YAGS"
      assert_select "div#session-info" do
        if logged_in?
          assert_select "a[href=/users/logout]", /logout/i
        else
          assert_select "a[href=/users/login]", /login/i
        end
      end
    end
    assert_select "div.menu-bar" do
      if current_test_user.instructor?
        assert_select "a[href=/lab]", /lab/i
        assert_select "a[href=/lab/list_courses]", /list\scourses/i
        assert_select "a[href=/lab/add_scenario]", /add\sscenario/i
        assert_select "a[href=/users/add_student]", /add\sstudent/i
      elsif current_test_user.admin?
        assert_select "a[href=/users]", /users/i
        assert_select "a[href=/users/list_users]", /list\s.*users/i
        assert_select "a[href=/users/add_instructor]", /add\sinstructor/i
        assert_select "a[href=/users/change_student_password]", /change\sstudent\spassword/i
      else
        assert_select "a[href=/bench]", /bench/i
        assert_select "a[href=/bench/list_vials]", /list\svials/i
        assert_select "a[href=/bench/mate_flies]", /mate\sflies/i
        assert_select "a[href=/bench/add_rack]", /.*rack/i
      end
    end
  end
  
  def assert_redirected_to_login
    assert_redirected_to :controller => 'users', :action => 'login'
  end
  
  # could be generalized easily
  # presently only works with :controller, :action, and :id explicitly set
  def assert_rjs_redirect(options = {})
    assert_equal "window.location.href = \"/#{options[:controller]}/#{options[:action]}/#{options[:id]}\";", @response.body
  end
  
  def assert_dependents_destroyed(main_class, dependent_class, options)
    number_of_old_objects = main_class.find(:all).size
    number_of_old_dependents = dependent_class.find(:all).size
    assert_not_nil main_class.find_by_id(options[:fixture_id])
    assert_equal options[:number_of_dependents], 
        dependent_class.send("find_all_by_" + options[:foreign_key], options[:fixture_id]).size
    
    main_class.find(options[:fixture_id]).destroy
    assert_equal number_of_old_objects - 1, main_class.find(:all).size
    assert_nil main_class.find_by_id(options[:fixture_id])
    assert_equal 0, dependent_class.send("find_all_by_" + options[:foreign_key], options[:fixture_id]).size
    assert_equal number_of_old_dependents - options[:number_of_dependents], dependent_class.find(:all).size
  end
  
  def assert_basically_the_same_fly(fly1, fly2)
    assert_equal fly1.species.characters, fly2.species.characters
    fly1.species.order(fly1.genotypes).zup(fly2.genotypes) do |fly1_genotype, fly2_genotype|
      assert_equal fly1_genotype.gene_number, fly2_genotype.gene_number, "gene number"
      assert_equal fly1_genotype.mom_allele, fly2_genotype.mom_allele, "mom allele for #{fly1_genotype.gene_number}"
      assert_equal fly1_genotype.dad_allele, fly2_genotype.dad_allele, "dad allele for #{fly1_genotype.gene_number}"
    end
  end
  
  def assert_xhr_post_only(action, params = {}, session = {})
    assert_rejected_http_methods [:xhr_get, :post, :get], action, params, session
  end
  
  def assert_rejected_http_methods(rejected_methods, action, params = {}, session = {})
    if rejected_methods.include?(:xhr_get)
      xhr :get, action, params, session
      assert_response 401, "should reject xhr get of action #{action.to_s}"
    end
    if rejected_methods.include?(:xhr_post)
      xhr :post, action, params, session
      assert_response 401, "should reject xhr post of action #{action.to_s}"
    end
    if rejected_methods.include?(:post)
      post action, params, session
      assert_response 401, "should reject normal post of action #{action.to_s}"
    end
    if rejected_methods.include?(:get)
      get action, params, session
      assert_response 401, "should reject normal get of action #{action.to_s}"    
    end
  end

  # The container can be an array of flies or any general container that has
  # a flies method (like a Vial).
  def phenotypes_of(container, character)
    if (container.respond_to?(:flies))
      flies = container.flies
    else
      flies = container
    end
    flies.map { |fly| fly.phenotype(character) }
  end

  def assert_equal_set(expected, actual, message=nil)
    assert_equal expected.sort_by { |p| p.to_s }, actual.sort_by { |p| p.to_s }, message
  end
    
  def logged_in?
    session[:current_user_id] != nil
  end
  
  def current_test_user
    User.find(session[:current_user_id])
  end
  
  def user_session(privilege)
    case privilege
    when :steve
      { :current_user_id => 1 }
    when :jeremy
      { :current_user_id => 3 }
    when :randy
      { :current_user_id => 4 }
    when :mendel
      { :current_user_id => 5 }
    when :darwin
      { :current_user_id => 6 }
    when :manage_student
      { :current_user_id => 5 }
    when :calvin
      { :current_user_id => 2 }
    when :keith
      { :current_user_id => 7 }
    else
      {}
    end
  end
  
end
