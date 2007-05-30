require "#{File.dirname(__FILE__)}/../test_helper"

class FullMigrationTest < ActionController::IntegrationTest
  
  def test_full_migration
    drop_all_tables
    see_empty_schema
    
    migrate
    see_full_schema
    
    migrate :version => 0
    see_empty_schema
    
    migrate
    see_full_schema
  end
  
  def see_full_schema
    assert_schema do |s|
      s.table :flies do |t|
        t.column :id,          :integer
#        t.column :locus_mom,   :integer
#        t.column :locus_dad,   :integer
        t.column :vial_id,     :integer
      end
      
      s.table :vials do |t|
        t.column :id,           :integer
        t.column :label,        :string
      end
      
      s.table :genotypes do |t|
        t.column :id,          :integer
        t.column :fly_id,       :integer
        t.column :position,     :float
        t.column :mom_allele,   :integer
        t.column :dad_allele,   :integer
      end
    end
  end
  
  def see_empty_schema
    assert_schema do |s|
    end
  end
  
end
