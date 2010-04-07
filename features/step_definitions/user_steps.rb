def create_groups_and_privileges!
  instructor = Group.find_or_create_by_name("instructor")
  manage_lab = Privilege.find_or_create_by_name("manage_lab")
  instructor.privileges << manage_lab
  instructor.save!
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

When /^I login as "([^\"]*)"$/ do |username|
  When 'I go to the login page'
  And 'I fill in "Username" with "mendel"'
  And 'I fill in "Password" with "mendel"'
  And 'I press "Login"'
  Then 'I should not see "Invalid login credentials"'
end
