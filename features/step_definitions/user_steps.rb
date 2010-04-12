def create_groups_and_privileges!
  instructor = Group.find_or_create_by_name("instructor")
  ["manage_lab", "manage_student"].each do |name|
    privilege = Privilege.find_or_create_by_name(name)
    instructor.privileges << privilege
  end
  instructor.save!

  student = Group.find_or_create_by_name("student")
  student.save!
end

Given /^only the following users$/ do |table|
  create_groups_and_privileges!
  User.all.each { |u| u.destroy }
  table.hashes.each do |hash|
    user = User.new(:username => hash[:username],
                    :email_address => hash[:email_address] || hash[:username],
                    :password => hash[:password],
                    :password_confirmation => hash[:password])
    user.group = Group.find_by_name(hash[:group])
    user.save!
  end
end

Given /^an instructor "([^\"]*)"$/ do |username|
  create_groups_and_privileges!
  User.all.each { |u| u.destroy }
  user = User.new(:username => username, :email_address => "#{username}@example.com",
                  :password => username, :password_confirmation => username)
  user.group = Group.find_by_name("instructor")
  user.save!
end

Given /^a student "([^\"]*)"$/ do |student_name|
  student = User.new(:username => student_name, :email_address => "#{student_name}@example.com",
                     :password => student_name, :password_confirmation => student_name)
  student.group = Group.find_by_name("student")
  student.save!
end

Given /^a student "([^\"]*)" in "([^\"]*)"$/ do |student_name, course_name|
  student = User.new(:username => student_name, :email_address => "#{student_name}@example.com",
                     :password => student_name, :password_confirmation => student_name)
  student.group = Group.find_by_name("student")
  student.save!

  course = Course.find_by_name(course_name)
  course.students << student
  course.save!
end


When /^I login as "([^\"]*)"$/ do |username|
  When 'I go to the login page'
  And 'I fill in "Username" with "mendel"'
  And 'I fill in "Password" with "mendel"'
  And 'I press "Login"'
  Then 'I should not see "Invalid login credentials"'
end
