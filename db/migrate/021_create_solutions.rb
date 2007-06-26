class CreateSolutions < ActiveRecord::Migration
  def self.up
    create_table :solutions do |t|
      t.column :vial_id, :integer
      t.column :number, :integer
    end
  end

  def self.down
    drop_table :solutions
  end
end
