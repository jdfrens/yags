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
        t.column :locus_mom,   :integer
        t.column :locus_dad,   :integer
      end
      
      s.table :vials do |t|
        t.column :id,           :integer
        t.column :label,        :string
      end
    end
  end
  
  def see_empty_schema
    assert_schema do |s|
    end
  end
  
end
