require File.dirname(__FILE__) + '/../../spec_helper'

describe Instructor::CoursesController do

  integrate_views

  describe "GET index" do
    it "should list courses" do
      get :index, {}, user_session(:mendel)
      assert_response :success

      assert_select "ul" do
        assert_select "li", "Peas pay attention"
      end
    end

    it "should list other courses" do
      get :index, {}, user_session(:darwin)
      assert_response :success

      assert_select "ul" do
        assert_select "li", "Natural selection"
        assert_select "li", "Interim to the Galapagos Islands"
      end
    end

    it "should redirect when not logged in" do
      get :index
      
      assert_redirected_to_login
    end


    it "should deny access if an administrator" do
      get :index, {}, user_session(:calvin)
      assert_response 401 # access denied
    end

    it "should deny access if a student" do
      get :index, {}, user_session(:steve)
      assert_response 401 # access denied
    end
  end

end
