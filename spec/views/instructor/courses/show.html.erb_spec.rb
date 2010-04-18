require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/instructor/courses/show.html.erb" do

  fixtures :all

  it "should render course" do
    assigns[:course] = course = Course.find_by_id(1)
    assigns[:students] = course.students
    
    render "instructor/courses/show"

    response.should have_selector("h1", :content => "Course: Peas pay attention")
    response.should have_selector("#table_of_student_solutions") do |solutions|
      solutions.should have_selector("table") do |table|
        table.should have_selector("tr:nth-child(2) th", :content => "jeremy")
        table.should have_selector("tr:nth-child(2) td:nth-child(3)", :content => "X")
        table.should have_selector("tr:nth-child(3) th", :content => "randy")
      end
    end
  end
end
