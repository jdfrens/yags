require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/add_student.html.erb" do

  it "should render a form" do
    assigns[:courses] = courses = []

    render "users/add_student"

    response.should have_selector("form") do |form|
      form.should have_selector("input#user_username")
      form.should have_selector("input#user_first_name")
      form.should have_selector("input#user_last_name")
      form.should have_selector("input#user_email_address")
      form.should have_selector("input#user_password")
      form.should have_selector("input#user_password_confirmation")
      form.should have_selector("select#user_course_id")
    end
  end

end
