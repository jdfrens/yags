class CreatePhenotypeAlternates < ActiveRecord::Migration
  def self.up
    create_table :phenotype_alternates do |t|
      t.column :scenario_id, :integer
      t.column :user_id,     :integer
      t.column :affected_character, :string
      t.column :original_phenotype, :string
      t.column :renamed_phenotype,  :string
    end
  end

  def self.down
    drop_table :phenotype_alternates
  end
end
