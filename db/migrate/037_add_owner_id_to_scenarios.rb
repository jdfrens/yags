class AddOwnerIdToScenarios < ActiveRecord::Migration
  def self.up
    add_column :scenarios, :owner_id, :integer
    
    Scenario.reset_column_information
    first_instructor = User.find_by_group_id(Group.find_by_name("instructor").id)
    if first_instructor
      Scenario.find(:all).each do |scenario|
        scenario.owner = first_instructor
        scenario.save!
      end
    end
  end

  def self.down
    remove_column :scenarios, :owner_id
  end
end
