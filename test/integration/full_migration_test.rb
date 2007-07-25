require "#{File.dirname(__FILE__)}/../test_helper"

class FullMigrationTest < ActionController::IntegrationTest
  
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
        t.column :id,              :integer
        t.column :label,           :string
        t.column :mom_id,          :integer
        t.column :dad_id,          :integer
        t.column :rack_id,         :integer
        t.column :pedigree_number, :integer
      end
      
      s.table :genotypes do |t|
        t.column :id,           :integer
        t.column :fly_id,       :integer
        t.column :mom_allele,   :integer
        t.column :dad_allele,   :integer
        t.column :gene_number,  :integer
      end
      
      s.table :courses do |t|
        t.column :id,            :integer
        t.column :instructor_id, :integer
        t.column :name,          :string
      end
      
      s.table :basic_preferences do |t|
        t.column :id,            :integer
        t.column :user_id,       :integer
        t.column :column,        :string
        t.column :row,           :string
        t.column :scenario_id,   :integer
        t.column :flies_number,  :integer
      end
      
      s.table :character_preferences do |t|
        t.column :id,               :integer
        t.column :user_id,          :integer
        t.column :hidden_character, :string
      end
      
      s.table :racks do |t|
        t.column :id,          :integer
        t.column :user_id,     :integer
        t.column :label,       :string
        t.column :scenario_id, :integer
      end
      
      s.table :solutions do |t|
        t.column :id,           :integer
        t.column :vial_id,      :integer
        t.column :number,       :integer
      end
      
      s.table :scenarios do |t|
        t.column :id,         :integer
        t.column :title,      :string
        t.column :owner_id,   :integer
      end
      
      s.table :scenario_preferences do |t|
        t.column :id,               :integer
        t.column :scenario_id,      :integer
        t.column :hidden_character, :string
      end
      
      s.table :renamed_characters do |t|
        t.column :id,                :integer
        t.column :scenario_id,       :integer
        t.column :renamed_character, :string
      end
      
      s.table :courses_scenarios do |t|
        t.column :course_id,   :integer
        t.column :scenario_id, :integer
      end
      
      s.table :phenotype_alternates do |t|
        t.column :id,          :integer
        t.column :scenario_id, :integer
        t.column :user_id,     :integer
        t.column :affected_character, :string
        t.column :original_phenotype, :string
        t.column :renamed_phenotype,  :string
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
        t.column "course_id",     :integer
        t.column "first_name",    :string
        t.column "last_name",     :string
      end
    end
  end
  
  def see_default_data
    assert_equal 3, Group.find(:all).size, "should be three groups"
    assert_group_exists "student"
    assert_group_exists "admin"
    assert_group_exists "instructor"
    
    assert_equal 4, Privilege.find(:all).size, "should be four privileges"
    assert_privilege_exists "manage_bench"
    assert_privilege_exists "manage_student"
    assert_privilege_exists "manage_lab"
    assert_privilege_exists "manage_instructor"
    
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
  
  def assert_group_exists(group_name)
    assert_equal 1, Group.find(:all).select { |g| g.name == group_name }.size,
        "should have #{group_name} group"
  end
  
  def assert_privilege_exists(privilege_name)
    assert_equal 1, Privilege.find(:all).select { |p| p.name == privilege_name }.size,
        "should have #{privilege_name} privilege"
  end
  
end
