class CreateScenarioPreferences < ActiveRecord::Migration
  def self.up
    create_table :scenario_preferences do |t|
      t.column :scenario_id, :integer
      t.column :character,   :string
    end
  end

  def self.down
    drop_table :scenario_preferences
  end
end
