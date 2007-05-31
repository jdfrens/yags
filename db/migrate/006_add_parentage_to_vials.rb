class AddParentageToVials < ActiveRecord::Migration
  def self.up
    add_column :vials, :mom_id, :integer
    add_column :vials, :dad_id, :integer
  end

  def self.down
    remove_column :vials, :mom_id
    remove_column :vials, :dad_id
  end
end
