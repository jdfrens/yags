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
        t.column :vial_id,     :integer
      end
      
      s.table :vials do |t|
        t.column :id,           :integer
        t.column :label,        :string
        t.column :mom_id,       :integer
        t.column :dad_id,       :integer
        t.column :user_id,      :integer
      end
      
      s.table :genotypes do |t|
        t.column :id,           :integer
        t.column :fly_id,       :integer
        t.column :mom_allele,   :integer
        t.column :dad_allele,   :integer
        t.column :gene_number,  :integer
      end
      
      # authentication
      s.table "groups" do |t|
        t.column "id",          :integer
        t.column "name",        :string
      end
      
      s.table "privileges" do |t|
        t.column "id",          :integer
        t.column "name",        :string
      end
      
      s.table "groups_privileges" do |t|
        t.column "id",           :integer
        t.column "group_id",     :integer
        t.column "privilege_id", :integer
      end
      
      s.table "users" do |t|
        t.column "id",            :integer
        t.column "username",      :string
        t.column "password_hash", :string
        t.column "group_id",      :integer
        t.column "email_address", :string
      end
    end
  end
  
  def see_empty_schema
    assert_schema do |s|
    end
  end
  
end
