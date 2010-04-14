require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/new_students.html.erb" do

  it "should render form" do
    assigns[:courses] = [stub_model(Course)]
    
    render "users/new_students"

    assert_select "form" do
      assert_select "label[for=student_csv]"
      assert_select "textarea#student_csv"
      assert_select "label[for=password]"
      assert_select "input#password"
      assert_select "label[for=course_id]"
      assert_select "select#user_course_id" do
        assert_select "option", 1
      end
      assert_select "label", 3
    end
  end

end
