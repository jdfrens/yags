class RemoveLocusOfFly < ActiveRecord::Migration
  def self.up
    remove_column :flies, :locus_dad
    remove_column :flies, :locus_mom
  end

  def self.down
    add_column :flies, :locus_dad, :integer
    add_column :flies, :locus_mom, :integer
  end
end
