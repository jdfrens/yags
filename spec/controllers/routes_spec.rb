require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  it "should have login path" do
    login_path.should == "/users/login"
  end

  it "should have logout path" do
    logout_path.should == "/users/logout"
  end
end

describe Instructor::CoursesController do
  it "should have index path" do
    instructor_courses_path.should == "/instructor/courses"
  end

  it "should have path to create a new course" do
    new_instructor_course_path.should == "/instructor/courses/new"
  end

  it "should have path to show a course" do
    course = mock_model(Course)
    instructor_course_path(course).should == "/instructor/courses/#{course.id}"
  end
end
