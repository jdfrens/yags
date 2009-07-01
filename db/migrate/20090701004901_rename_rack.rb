class RenameRack < ActiveRecord::Migration
  def self.up
    rename_table :racks, :shelves
    rename_column :vials, :rack_id, :shelf_id
  end

  def self.down
    rename_column :vials, :shelf_id, :rack_id
    rename_table :shelves, :racks
  end
end
