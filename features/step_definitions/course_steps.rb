Given /^a course "([^\"]*)" for "([^\"]*)"$/ do |course, instructor|
  course = Course.new(:name => course)
  course.instructor = User.find_by_username(instructor)
  course.save!
end
