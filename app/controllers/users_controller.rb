class UsersController < ApplicationController
  acts_as_login_controller
  
  restrict_to :manage_student, :only => [ :list_users, :add_student, :index, :delete_user]
  restrict_to :manage_student, :only => [ :change_student_password ]
  
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
    if params[:user]
      params[:user][:group] = Group.find_by_name('student')
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
  
  def delete_user
    if params[:id] and request.post?
      User.find(params[:id]).destroy
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
    User.find(:all, :conditions => "group_id = #{Group.find_by_name("student").id}").each do |student|
      @student_names_and_ids << [student.username, student.id]
    end
    if request.post? and params[:user]
      if User.find(params[:student_id]) and 
          params[:user][:password] == params[:user][:password_confirmation]
        User.find(params[:student_id]).update_attributes(params[:user])
        flash[:notice] = "Password Changed"
      else
        flash[:notice] = "Try Again"
      end
    else
      
    end
  end
  
  def redirect_user
    if current_user
      case current_user.group.name
      when "student"
        redirect_to :controller => "bench", :action => "index"
      when "admin"
        redirect_to :controller => "users", :action => "index"
      else
        redirect_to :controller => "users", :action => "logout" # because we don't know who they are.
      end
    else
      redirect_to :controller => "users", :action => "login"
    end
  end
  
end