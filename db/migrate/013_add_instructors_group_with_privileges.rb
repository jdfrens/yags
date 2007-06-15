class AddInstructorsGroupWithPrivileges < ActiveRecord::Migration
  def self.up
    instructor = Group.create!(:name => 'instructor')
    manage_lab = Privilege.create!(:name => 'manage_lab')
    manage_instructor = Privilege.create!(:name => 'manage_instructor')
    GroupPrivilege.create!(:group => instructor, :privilege => Privilege.find_by_name("manage_student"))
    GroupPrivilege.create!(:group => instructor, :privilege => manage_lab)
    GroupPrivilege.create!(:group => Group.find_by_name("admin"), :privilege => manage_instructor)
  end

  def self.down
    GroupPrivilege.find(:all).select { |gp|
      gp.group_id == Group.find_by_name("instructor").id and
      gp.privilege_id == Privilege.find_by_name("manage_student").id
    }.each { |gp| gp.destroy }
    GroupPrivilege.find(:all).select { |gp|
      gp.group_id == Group.find_by_name("instructor").id and
      gp.privilege_id == Privilege.find_by_name("manage_lab").id
    }.each { |gp| gp.destroy }
    GroupPrivilege.find(:all).select { |gp|
      gp.group_id == Group.find_by_name("admin").id and
      gp.privilege_id == Privilege.find_by_name("manage_instructor").id
    }.each { |gp| gp.destroy }
    Group.find_by_name("instructor").destroy
    Privilege.find_by_name("manage_lab").destroy
    Privilege.find_by_name("manage_instructor").destroy
  end
end
