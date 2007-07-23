class AddFliesNumberToBasicPreference < ActiveRecord::Migration
  def self.up
    add_column :basic_preferences, :flies_number, :integer
  end

  def self.down
    remove_column :basic_preferences, :flies_number
  end
end
