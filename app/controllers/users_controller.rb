class UsersController < ApplicationController
  acts_as_login_controller
  
  restrict_to :manage_student, :only => [ :list_users, :add_student, :index, :delete_user]
  restrict_to :manage_bench, :only => [ :change_password ]
  
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
      student = User.create!(params[:user])
      redirect_to :action => "list_users"
    end
  end
  
  def delete_user
    if params[:id] and request.post?
      User.find(params[:id]).destroy
    end
    redirect_to :action => :list_users
  end
  
  def change_password
    @user = current_user
    if request.post? 
      if User.hash_password(params[:old_password]) == @user.password_hash and 
          params[:user][:password] == params[:user][:password_confirmation]
        @user.update_attributes(params[:user])
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
      else
        redirect_to :controller => "users", :action => "logout" # because we don't know who they are.
      end
    else
      redirect_to :controller => "users", :action => "login"
    end
  end
end