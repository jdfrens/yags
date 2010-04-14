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
  end

end
