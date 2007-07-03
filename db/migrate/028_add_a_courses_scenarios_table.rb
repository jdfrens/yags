class AddACoursesScenariosTable < ActiveRecord::Migration
  def self.up
    create_table :courses_scenarios, :id => false do |t|
      t.column :scenario_id, :integer
      t.column :course_id,   :integer
    end
  end

  def self.down
    drop_table :courses_scenarios
  end
end
