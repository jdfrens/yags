require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/add_student.html.erb" do

  user_fixtures

  it "should render a form" do
    render "users/add_instructor"

    response.should have_selector("form") do |form|
      form.should have_selector("input#user_username")
      form.should have_selector("input#user_email_address")
      form.should have_selector("input#user_password")
      form.should have_selector("input#user_password_confirmation")
    end
  end

end
