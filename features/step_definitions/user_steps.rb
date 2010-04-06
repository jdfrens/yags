def create_groups_and_privileges!
  Group.find_or_create_by_name("instructor")
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
