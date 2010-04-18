require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/instructor/courses/index.html.erb" do

  it "should render no courses" do
    assigns[:courses] = []
    
    render "instructor/courses/index"

    response.should contain("You do not have any courses")
  end

  it "should render one course" do
    assigns[:courses] = [mock_model(Course, :name => "BIO 143")]

    render "instructor/courses/index"

    response.should have_selector("a", :content => "BIO 143")
    response.should have_selector("a", :title => "Delete BIO 143")
  end
end
