require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/layouts/_menu_bar.html.erb" do
  it "should render a menu for an instructor" do
    user = mock_model(User, :username => "Darwin", :instructor? => true)
    template.should_receive(:current_user).at_least(:once).and_return(user)

    render "layouts/_menu_bar"

    assert_select "div.menu-bar" do
      assert_select "a[href=/lab]", /lab/i
      assert_select "a[href=/lab/list_courses]", /list\scourses/i
      assert_select "a[href=/lab/add_scenario]", /add\sscenario/i
      assert_select "a[href=/users/add_student]", /add\sstudent/i
    end
  end

  it "should render a menu for an admin" do
    user = mock_model(User, :username => "Linus", :instructor? => false, :admin? => true)
    template.should_receive(:current_user).at_least(:once).and_return(user)

    render "layouts/_menu_bar"

    assert_select "div.menu-bar" do
      assert_select "a[href=/users]", /users/i
      assert_select "a[href=/users/list_users]", /list\s.*users/i
      assert_select "a[href=/users/add_instructor]", /add\sinstructor/i
      assert_select "a[href=/users/change_student_password]", /change\sstudent\spassword/i
    end
  end

  it "should render a menu for a student" do
    user = mock_model(User, :username => "Charlie Brown", :instructor? => false, :admin? => false)
    template.should_receive(:current_user).at_least(:once).and_return(user)

    render "layouts/_menu_bar"

    assert_select "div.menu-bar" do
      assert_select "a[href=/bench]", /bench/i
      assert_select "a[href=/bench/list_vials]", /list\svials/i
      assert_select "a[href=/bench/mate_flies]", /mate\sflies/i
      assert_select "a[href=/bench/add_shelf]", /.*rack/i
    end
  end
end
