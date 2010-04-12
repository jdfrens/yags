Given /^only the following users$/ do |table|
  create_groups_and_privileges!
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
  create_user(username, "instructor")
end

Given /^an admin "([^\"]*)"$/ do |username|
  create_groups_and_privileges!
  create_user(username, "admin")
end

Given /^a student "([^\"]*)"$/ do |student_name|
  create_user(student_name, "student")
end

Given /^a student "([^\"]*)" in "([^\"]*)"$/ do |student_name, course_name|
  student = create_user(student_name, "student")
  course = Course.find_by_name(course_name)
  course.students << student
  course.save!
end


When /^I log in as "([^\"]*)"$/ do |username|
  When 'I go to the login page'
  And %{I fill in "Username" with "#{username}"}
  And %{I fill in "Password" with "#{username}"}
  And 'I press "Login"'
  Then 'I should not see "Invalid login credentials"'
end

def create_user(username, group)
  student = User.new(:username => username, :email_address => "#{username}@example.com",
                     :password => username, :password_confirmation => username)
  student.group = Group.find_by_name(group)
  student.save!
  student
end

def add_privileges!(group, privileges)
  privileges.each do |name|
    privilege = Privilege.find_or_create_by_name(name)
    group.privileges << privilege
  end
  group.save!
end

def create_groups_and_privileges!
  admin = Group.find_or_create_by_name('admin')
  add_privileges!(admin, ['manage_student', "manage_instructor"])

  instructor = Group.find_or_create_by_name("instructor")
  add_privileges!(instructor, ["manage_lab", "manage_student"])

  student = Group.find_or_create_by_name('student')
  add_privileges!(student, ["manage_bench"])
end
