require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/layouts/application.html.erb" do

  context "rendering a bunch of stuff without a user" do
    before do
      template.should_receive(:current_user).at_least(:once).and_return(nil)
      render "layouts/application"
    end

    it "should have a header" do
      response.should have_selector("div.header") do |header|
        header.should have_selector("h1", :content => "YAGS")
        header.should have_selector("#session-info") do |session|
          session.should have_selector("a", :href => "/users/login", :content => "Login")
        end
      end
    end

    it "should not have any menu links" do
      response.should_not have_selector("div.menu-bar a")
    end
  end

  it "should render a bunch of stuff for an instructor" do
    user = mock_model(User, :username => "Darwin", :instructor? => true)
    template.should_receive(:current_user).at_least(:once).and_return(user)

    render "layouts/application"

    assert_select "div.header" do
      assert_select "h1", "YAGS"
      assert_select "div#session-info" do
        assert_select "a[href=/users/logout]", /logout/i
      end
    end
    assert_select "div.menu-bar" do
      assert_select "a[href=/lab]", /lab/i
      assert_select "a[href=/lab/list_courses]", /list\scourses/i
      assert_select "a[href=/lab/add_scenario]", /add\sscenario/i
      assert_select "a[href=/users/add_student]", /add\sstudent/i
    end
  end

  it "should render a bunch of stuff for an admin" do
    user = mock_model(User, :username => "Linus", :instructor? => false, :admin? => true)
    template.should_receive(:current_user).at_least(:once).and_return(user)

    render "layouts/application"

    assert_select "div.header" do
      assert_select "h1", "YAGS"
      assert_select "div#session-info" do
        assert_select "a[href=/users/logout]", /logout/i
      end
    end
    assert_select "div.menu-bar" do
      assert_select "a[href=/users]", /users/i
      assert_select "a[href=/users/list_users]", /list\s.*users/i
      assert_select "a[href=/users/add_instructor]", /add\sinstructor/i
      assert_select "a[href=/users/change_student_password]", /change\sstudent\spassword/i
    end
  end

  it "should render a bunch of stuff for a student" do
    user = mock_model(User, :username => "Charlie Brown", :instructor? => false, :admin? => false)
    template.should_receive(:current_user).at_least(:once).and_return(user)

    render "layouts/application"

    assert_select "div.header" do
      assert_select "h1", "YAGS"
      assert_select "div#session-info" do
        assert_select "a[href=/users/logout]", /logout/i
      end
    end
    assert_select "div.menu-bar" do
      assert_select "a[href=/bench]", /bench/i
      assert_select "a[href=/bench/list_vials]", /list\svials/i
      assert_select "a[href=/bench/mate_flies]", /mate\sflies/i
      assert_select "a[href=/bench/add_shelf]", /.*rack/i
    end
  end

end