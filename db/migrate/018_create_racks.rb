class CreateRacks < ActiveRecord::Migration
  def self.up
    create_table :racks do |t|
      t.column :user_id,  :integer
      t.column :label,    :string
    end
    
    add_column :vials, :rack_id, :integer
    
    User.find(:all).each do |user|
      primary_rack = Rack.create! :user_id => user.id, :label => "bench"
      Rack.create! :user_id => user.id, :label => "stock"
      Vial.find(:all, :conditions => "user_id = #{user.id}").each do |vial|
        vial.rack_id = primary_rack.id
        vial.save!
      end
    end
    
    remove_column :vials, :user_id
  end

  def self.down
    add_column :vials, :user_id, :integer
    Vial.find(:all).each do |vial|
      vial.user_id = Rack.find(vial.rack_id).user_id
      vial.save!
    end
    
    drop_table :racks
    remove_column :vials, :rack_id
  end
end
