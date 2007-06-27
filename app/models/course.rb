class Course < ActiveRecord::Base
  belongs_to :instructor, :class_name => "User", :foreign_key => "instructor_id"
  has_many :students, :class_name => "User", :dependent => :destroy # TEST THIS!
  
end
