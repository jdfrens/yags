class AddUserIdToVialAndMakeStudentGroup < ActiveRecord::Migration
  def self.up
    add_column :vials, :user_id, :integer
  
    student = Group.create!(:name => 'student')
    manage_bench = Privilege.create!(:name => 'manage_bench')
    GroupPrivilege.create!(:group => student, :privilege => manage_bench )
  end

  def self.down
    remove_column :vials, :user_id
  
    Group.find(:all).select { |g| g.name == "student" }.each do |g| 
      GroupPrivilege.find(:all).select { |gp| gp.group_id == g.id }.each do |gp| 
        gp.destroy 
      end
      g.destroy 
    end
    Privilege.find(:all).select { |p| p.name == "manage_bench" }.each do |p| 
      p.destroy 
    end
  end
end
