class UsersController < ApplicationController
  acts_as_login_controller
  
  restrict_to :manage_student, :only => [ :list_users, :add_student, :delete_user, 
      :change_student_password ]
  restrict_to :manage_instructor, :only => [ :add_instructor, :index ]
  
  redirect_after_login do |controller|
    { :controller => 'users', :action => 'redirect_user' }
  end
  
  def index
    @username = current_user.username
  end
  
  def list_users
    @users = User.find(:all)
  end
  
  def add_student
    @course_names_and_ids = []
    courses = (current_user.instructor? ? current_user.instructs : Course.find(:all))
    courses.each do |course|
      @course_names_and_ids << [course.name, course.id]
    end
    if params[:user]
      params[:user][:group] = Group.find_by_name('student')
      params[:user][:course_id] = params[:course_id] # this line is annoying to need
      @user = User.new(params[:user])
      @user.save!
      Rack.create! :user_id => @user.id, :label => 'bench'
      Rack.create! :user_id => @user.id, :label => 'stock'
      redirect_to :action => "list_users"
    else
      render
    end
  rescue ActiveRecord::RecordInvalid
    render
  end
  
  # this isn't very DRY.  maybe it could be combined with the above method somehow
  def add_instructor
    if params[:user]
      params[:user][:group] = Group.find_by_name('instructor')
      @user = User.new(params[:user])
      @user.save!
      redirect_to :action => "list_users"
    else
      render
    end
  rescue ActiveRecord::RecordInvalid
    render
  end
  
  def delete_user
    if params[:id] and request.post? and 
        current_user.has_authority_over(User.find(params[:id]))
      @user = User.find(params[:id]).destroy
      flash[:notice] = "#{@user.username} has been deleted"
    end
    redirect_to :action => :list_users
  end
  
  def change_password
    if current_user
      if request.post?
        if User.hash_password(params[:old_password]) == current_user.password_hash and 
            params[:user][:password] == params[:user][:password_confirmation]
          current_user.update_attributes(params[:user])
          flash[:notice] = "Password Changed"
        else
          flash[:notice] = "Try Again"
        end
      end
    else
      redirect_to :controller => "users", :action => "login"
    end
  end
  
  def change_student_password
    @student_names_and_ids = []
    students = (current_user.group.name == "instructor" ? current_user.students : 
        User.find(:all, :conditions => "group_id = #{Group.find_by_name("student").id}"))
    students.each do |student|
      @student_names_and_ids << [student.username, student.id]
    end
    if request.post? and params[:user]
      student = User.find_by_id(params[:student_id])
      if student and current_user.has_authority_over(student) and
          params[:user][:password] == params[:user][:password_confirmation]
        student.update_attributes(params[:user])
        flash[:notice] = "Password Changed"
      else
        flash[:notice] = "Try Again"
      end
    end
  end
  
  def redirect_user
    if current_user
      case current_user.group.name
      when "student"
        redirect_to :controller => "bench", :action => "index"
      when "admin"
        redirect_to :controller => "users", :action => "index"
      when "instructor"
        redirect_to :controller => "lab", :action => "index"
      else
        redirect_to :controller => "users", :action => "logout" # because we don't know who they are.
      end
    else
      redirect_to :controller => "users", :action => "login"
    end
  end
  
end