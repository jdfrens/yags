class AddVialIdToFlies < ActiveRecord::Migration
  def self.up
    add_column :flies, :vial_id, :integer
  end
  
  def self.down
    remove_column :flies, :vial_id
  end
end
