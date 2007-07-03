class Course < ActiveRecord::Base
  belongs_to :instructor, :class_name => "User", :foreign_key => "instructor_id"
  has_many :students, :class_name => "User", :dependent => :destroy
  has_and_belongs_to_many :scenarios
  
  # Temp TODO:
  
  # allow the instructors to add scenarios to their classes.
  
end
