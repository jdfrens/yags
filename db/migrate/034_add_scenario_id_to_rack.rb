class AddScenarioIdToRack < ActiveRecord::Migration
  def self.up
    add_column :racks, :scenario_id, :integer
    
    User.find(:all).select { |u| u.student? }.each do |student|
      unless student.current_scenario
        if student.enrolled_in.scenarios.first
          student.current_scenario_id = student.enrolled_in.scenarios.first.id if student.racks.first
        else
          student.racks.clear
        end
      end
      student.racks.each do |rack|
        rack.scenario_id = student.current_scenario.id
        rack.save!
      end
    end
  end

  def self.down
    remove_column :racks, :scenario_id
  end
end
