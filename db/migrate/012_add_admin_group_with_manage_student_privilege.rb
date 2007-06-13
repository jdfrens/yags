class AddAdminGroupWithManageStudentPrivilege < ActiveRecord::Migration
  def self.up
    admin = Group.create!(:name => 'admin')
    manage_student = Privilege.create!(:name => 'manage_student')
    GroupPrivilege.create!(:group => admin, :privilege => manage_student )
  end

  def self.down
    GroupPrivilege.find(:all).select { |gp|
      gp.group_id == Group.find_by_name("admin").id and
      gp.privilege_id == Privilege.find_by_name("manage_student").id
    }.each { |gp| gp.destroy }
    Group.find_by_name("admin").destroy
    Privilege.find_by_name("manage_student").destroy
  end
end
