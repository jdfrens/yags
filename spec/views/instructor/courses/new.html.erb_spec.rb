require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/instructor/courses/new.html.erb" do

  it "should render a form" do
    assigns[:course] = stub_model(Course)
    
    render "instructor/courses/new"

    response.should have_selector("h1", :content => "Add Course")
    response.should have_selector("form") do |form|
      form.should have_selector("input#course_name")
    end
  end

end
