# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'
require 'webrat'
require 'shoulda'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

module UserMacros

  def user_fixtures
    fixtures :users, :groups, :privileges, :groups_privileges
  end

end

module ModelHelpers

  # TODO: stinky
  def phenotypes_of(container, character)
    if (container.respond_to?(:flies))
      flies = container.flies
    else
      flies = container
    end
    flies.map { |fly| fly.phenotype(character) }
  end

  # TODO: stinky
  def assert_basically_the_same_fly(fly1, fly2)
    assert_equal fly1.species.characters, fly2.species.characters
    fly1.species.order(fly1.genotypes).zup(fly2.genotypes) do |fly1_genotype, fly2_genotype|
      assert_equal fly1_genotype.gene_number, fly2_genotype.gene_number, "gene number"
      assert_equal fly1_genotype.mom_allele, fly2_genotype.mom_allele, "mom allele for #{fly1_genotype.gene_number}"
      assert_equal fly1_genotype.dad_allele, fly2_genotype.dad_allele, "dad allele for #{fly1_genotype.gene_number}"
    end
  end

end

module SessionHelpers

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
  
  def logged_in?
    session[:current_user_id] != nil
  end

  def assert_redirected_to_login
    assert_redirected_to :controller => 'users', :action => 'login'
  end

end

module HttpMethodsHelpers

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

  def assert_rjs_redirect(options = {})
    assert_equal "window.location.href = \"/#{options[:controller]}/#{options[:action]}/#{options[:id]}\";", @response.body
  end

end

module StandardLayoutHelpers

  def assert_standard_layout
    # FIXME: write a view spec
    # TODO: get rid of this method
  end

end

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  config.include ModelHelpers
  config.extend UserMacros
  config.include SessionHelpers
  config.include StandardLayoutHelpers  # TODO: get rid of this
  config.include HttpMethodsHelpers
end
