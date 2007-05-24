class CreateVials < ActiveRecord::Migration
  def self.up
    create_table :vials do |t|
      t.column :label, :string
    end
  end

  def self.down
    drop_table :vials
  end
end
