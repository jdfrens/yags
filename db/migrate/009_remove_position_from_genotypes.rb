class RemovePositionFromGenotypes < ActiveRecord::Migration
  def self.up
    remove_column :genotypes, :position
  end

  def self.down
    add_column :genotypes, :position, :float
  end
end
