require 'fastercsv'

class UsersController < ApplicationController
  acts_as_login_controller
  
  restrict_to :manage_student, :only => [ :list_users, :add_student, :delete_user, 
      :change_student_password, :batch_add_students ]
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
  
  def batch_add_students
    if request.post? && params[:student_csv] && params[:user] && params[:password]
      if current_user.admin? || 
          current_user.instructs.include?(Course.find_by_id(params[:user][:course_id]))
        number_added = 0
        FasterCSV.parse(params[:student_csv]) do |row|
          student = User.new(params[:user])
          row.each { |e| e.strip! if e }
          student.last_name     = row.shift
          student.first_name    = row.shift
          student.email_address = row.shift
          student.username      = student.email_address.split('@').first if student.email_address
          student.group         = Group.find_by_name "student"
          student.password_hash = User.hash_password(params[:password])
          # TODO handle a blank password correctly! (right now it doesn't care if the password is blank!)
          student.save
          number_added += 1 if student.save
        end
        flash[:notice] = "#{number_added} students added!"
      else
        flash[:notice] = "Permission denied!" # TODO should that be a flash[:error] ? (not tested now)
      end
      if current_user.admin?
        redirect_to :action => "list_users"
      else # if instructor
        redirect_to :controller => "lab", :action => "view_course", :id => params[:user][:course_id]
      end
    else
      @courses = (current_user.instructor? ? current_user.instructs : Course.find(:all))
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