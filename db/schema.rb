# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 37) do

  create_table "basic_preferences", :force => true do |t|
    t.integer "user_id"
    t.string  "column"
    t.string  "row"
    t.integer "scenario_id"
    t.integer "flies_number"
  end

  create_table "character_preferences", :force => true do |t|
    t.integer "user_id"
    t.string  "hidden_character"
  end

  create_table "courses", :force => true do |t|
    t.integer "instructor_id"
    t.string  "name"
  end

  create_table "courses_scenarios", :id => false, :force => true do |t|
    t.integer "scenario_id"
    t.integer "course_id"
  end

  create_table "flies", :force => true do |t|
    t.integer "vial_id"
  end

  create_table "genotypes", :force => true do |t|
    t.integer "fly_id"
    t.integer "mom_allele"
    t.integer "dad_allele"
    t.integer "gene_number"
  end

  create_table "groups", :force => true do |t|
    t.string "name"
  end

  create_table "groups_privileges", :force => true do |t|
    t.integer "group_id"
    t.integer "privilege_id"
  end

  create_table "phenotype_alternates", :force => true do |t|
    t.integer "scenario_id"
    t.integer "user_id"
    t.string  "affected_character"
    t.string  "original_phenotype"
    t.string  "renamed_phenotype"
  end

  create_table "privileges", :force => true do |t|
    t.string "name"
  end

  create_table "racks", :force => true do |t|
    t.integer "user_id"
    t.string  "label"
    t.integer "scenario_id"
  end

  create_table "renamed_characters", :force => true do |t|
    t.integer "scenario_id"
    t.string  "renamed_character"
  end

  create_table "scenario_preferences", :force => true do |t|
    t.integer "scenario_id"
    t.string  "hidden_character"
  end

  create_table "scenarios", :force => true do |t|
    t.string  "title"
    t.integer "owner_id"
  end

  create_table "solutions", :force => true do |t|
    t.integer "vial_id"
    t.integer "number"
  end

  create_table "users", :force => true do |t|
    t.string  "username"
    t.string  "password_hash"
    t.string  "email_address"
    t.integer "group_id"
    t.integer "course_id"
    t.string  "first_name"
    t.string  "last_name"
  end

  create_table "vials", :force => true do |t|
    t.string  "label"
    t.integer "mom_id"
    t.integer "dad_id"
    t.integer "rack_id"
    t.integer "pedigree_number"
  end

end
