class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.column :instructor_id, :integer
      t.column :name,          :string
    end
    add_column :users, :course_id, :integer
  end

  def self.down
    drop_table :courses
    remove_column :users, :course_id
  end
end
