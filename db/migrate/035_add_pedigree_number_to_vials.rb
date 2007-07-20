class AddPedigreeNumberToVials < ActiveRecord::Migration
  def self.up
    add_column :vials, :pedigree_number, :integer
    
    Vial.reset_column_information
    Vial.find(:all).each do |vial|
      vial.get_pedigree_number
      vial.save!
    end
  end

  def self.down
    remove_column :vials, :pedigree_number
  end
end
