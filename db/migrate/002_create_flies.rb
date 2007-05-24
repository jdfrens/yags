class CreateFlies < ActiveRecord::Migration
  def self.up
    create_table :flies do |t|
      t.column :locus_mom, :integer
      t.column :locus_dad, :integer
    end
  end

  def self.down
    drop_table :flies
  end
end
