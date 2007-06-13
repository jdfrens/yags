require "#{File.dirname(__FILE__)}/../test_helper"

class FullMigrationTest < ActionController::IntegrationTest

  user_fixtures
  
  def test_full_migration
    drop_all_tables
    see_empty_schema
    
    migrate
    see_full_schema
    see_default_data
    
    migrate :version => 0
    see_empty_schema
    
    migrate
    see_full_schema
    see_default_data
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
  
  def see_default_data
    assert_equal 1, Group.find(:all).size, "should be one group"
    assert_equal 1, Group.find(:all).select { |g| g.name == "student" }.size,
        "should have student group"
    
    assert_equal 1, Privilege.find(:all).size, "should be one privilege"
    assert_equal 1, Privilege.find(:all).select { |p| p.name == "manage_bench" }.size,
        "should have manage bench privilege"
    
    assert_equal 1, GroupPrivilege.find(:all).size, "should be one group privilege mapping"
    assert_equal 1, GroupPrivilege.find(:all).select { |gp| # why can't this be a do end block?
      gp.group_id == Group.find_by_name("student").id and
      gp.privilege_id == Privilege.find_by_name("manage_bench").id
    }.size, "should be mapping between student and manage bench"
  end
  
  def see_empty_schema
    assert_schema do |s|
    end
  end
  
end
