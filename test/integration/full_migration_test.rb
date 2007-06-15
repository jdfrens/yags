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
    assert_equal 3, Group.find(:all).size, "should be three groups"
    assert_equal 1, Group.find(:all).select { |g| g.name == "student" }.size, "should have student group"
    assert_equal 1, Group.find(:all).select { |g| g.name == "admin" }.size, "should have admin group"
    assert_equal 1, Group.find(:all).select { |g| g.name == "admin" }.size, "should have instructor group"
    
    assert_equal 4, Privilege.find(:all).size, "should be two privileges"
    assert_equal 1, Privilege.find(:all).select { |p| p.name == "manage_bench" }.size, "should have manage_bench privilege"
    assert_equal 1, Privilege.find(:all).select { |p| p.name == "manage_student" }.size, "should have manage_student privilege"
    assert_equal 1, Privilege.find(:all).select { |p| p.name == "manage_lab" }.size, "should have manage_lab privilege"
    assert_equal 1, Privilege.find(:all).select { |p| p.name == "manage_instructor" }.size, "should have manage_instructor privilege"
    
    assert_equal 5, GroupPrivilege.find(:all).size, "should be five group privilege mappings"
    assert_mapping_between "student", "manage_bench"
    assert_mapping_between "admin", "manage_student"
    assert_mapping_between "admin", "manage_instructor"
    assert_mapping_between "instructor", "manage_lab"
    assert_mapping_between "instructor", "manage_student"
  end
  
  def see_empty_schema
    assert_schema do |s|
    end
  end
  
  # helpers
  
  # private
  
  def assert_mapping_between(group_name, privilege_name)
    assert_equal 1, GroupPrivilege.find(:all).select { |gp| # why can't this be a "do end" block?
      if group = Group.find_by_name(group_name) and privilege = Privilege.find_by_name(privilege_name)
        gp.group_id == group.id and gp.privilege_id == privilege.id
      else; false; end
    }.size, "should be mapping between #{group_name} and #{privilege_name}"
  end
  
end
