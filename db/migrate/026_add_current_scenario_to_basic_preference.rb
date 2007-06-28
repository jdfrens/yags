class AddCurrentScenarioToBasicPreference < ActiveRecord::Migration
  def self.up
    add_column :basic_preferences, :scenario_id, :integer
  end

  def self.down
    remove_column :basic_preferences, :scenario_id
  end
end
