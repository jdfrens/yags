class CreateScenarios < ActiveRecord::Migration
  def self.up
    create_table :scenarios do |t|
      t.column :title, :string
    end
  end

  def self.down
    drop_table :scenarios
  end
end
