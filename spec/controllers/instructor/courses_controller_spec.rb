require File.dirname(__FILE__) + '/../../spec_helper'

describe Instructor::CoursesController do

  integrate_views

  user_fixtures
  fixtures :courses

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

  describe "GET new" do
    it "should create a new course and render form" do
      course = mock_model(Course, :name => "")

      Course.should_receive(:new).and_return(course)

      get :new, {}, user_session(:instructor)

      response.should render_template("instructor/courses/new")
      assigns[:course].should == course
    end

    it "should redirect when not logged in" do
      get :new

      response.should redirect_to(login_path)
    end

    it "should deny access if a student" do
      get :new, {}, user_session(:student)

      response.should_not be_authorized
    end
  end

  describe "POST create" do
    it "should create a course" do
      course = mock_model(Course)

      Course.should_receive(:create!).
              with("name" => "From Muck to Mammals", "instructor_id" => users(:darwin).id).
              and_return(course)

      post :create, { :course => { :name => "From Muck to Mammals" } }, user_session(:darwin)

      response.should redirect_to(instructor_courses_path)
    end

    it "should redirect when not logged in" do
      post :create, { :course => { :name => "Why Aliens are afraid to visit earth" } }
      response.should redirect_to(login_path)
    end

    it "should deny access when logged in as administrator" do
      post :create, { :course => { :name => "Byker's Bio Course" } }, user_session(:calvin)

      response.should_not be_authorized
    end

    it "should deny access when logged in as a student" do
      post :create, { :course => { :name => "The art of jean selection" } }, user_session(:steve)

      response.should_not be_authorized
    end
  end
end
