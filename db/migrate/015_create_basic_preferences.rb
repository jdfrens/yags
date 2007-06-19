class CreateBasicPreferences < ActiveRecord::Migration
  def self.up
    create_table :basic_preferences do |t|
      t.column :user_id, :integer
      t.column :column,  :string
      t.column :row,     :string
    end
  end

  def self.down
    drop_table :basic_preferences
  end
end
