require 'fastercsv'

class UsersController < ApplicationController
  acts_as_login_controller

  restrict_to :manage_student, :only => [ :list_users, :add_student, :delete_user,
                                          :change_student_password, :create_students, :new_students ]
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
    if request.post?
      @user = create_student(params[:user])
      redirect_to :action => "list_users"
    else
      @courses = (current_user.instructor? ? current_user.instructs : Course.find(:all))
      render
    end
  rescue ActiveRecord::RecordInvalid
    render
  end

  # this isn't very DRY.  maybe it could be combined with the above method somehow
  def add_instructor
    if request.post?
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

  def new_students
    @courses = current_user.instructor? ? current_user.instructs : Course.all
  end

  def create_students
    if params[:password].blank?
      flash[:error] = "A password must be specified."
      @courses = current_user.instructor? ? current_user.instructs : Course.all
      render "new_students"
    elsif params[:student_csv].blank?
      flash[:error] = "No students were specified."
      @courses = current_user.instructor? ? current_user.instructs : Course.all
      render "new_students"
    elsif not (current_user.admin? || current_user.instructs.include?(Course.find_by_id(params[:course_id])))
      render :text => "You do not have the proper privileges to access this page.", :status => 401
    else
      course = Course.find(params[:course_id])
      number_added = User.batch_create!(params[:student_csv], params[:password], course)
      flash[:notice] = "#{number_added} students added!"
      if current_user.admin?
        redirect_to :action => "list_users"
      else # if instructor
        redirect_to [:instructor, course]
      end
    end
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
          flash.now[:notice] = "Password Changed"
        else
          flash.now[:error] = "Try Again"
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

#
# Helpers
#
  private

  def create_student(attributes)
    user = User.new(attributes)
    user.group = Group.find_by_name('student')
    user.save!
    user
  end

end
