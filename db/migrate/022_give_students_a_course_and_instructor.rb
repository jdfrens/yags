class GiveStudentsACourseAndInstructor < ActiveRecord::Migration
  def self.up
    instructor_group_id = Group.find_by_name('instructor').id
    default_instructor = User.find_by_group_id(instructor_group_id)
    if default_instructor.nil?
      default_instructor = User.new(:username => 'mendel', :email_address => 'gardener@monastery.foo',
             :password_hash => User.hash_password('peas'),
             :group => Group.find_by_name('instructor'))
      default_instructor.save!
    end
    
    default_course = Course.find_by_instructor_id(default_instructor.id)
    if default_course.nil?
      default_course = Course.new(:instructor_id => default_instructor.id, :name => 'Biology 141' )
      default_course.save!
    end  
    
    student_group_id = Group.find_by_name('student').id
    User.find(:all).select { |u| u.group_id == student_group_id }.each do |student|
      if student.course_id.nil? or Course.find_by_id(student.course_id).nil?
        student.course_id = default_course.id
        student.save!
      end
    end
  end

  def self.down
    # Sorry, it's not worth trying to undo any of this data migration.
  end
end
