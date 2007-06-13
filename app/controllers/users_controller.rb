class UsersController < ApplicationController
  acts_as_login_controller
  
  restrict_to :manage_student, :only => [ :list_users, :add_student, :index ]

  redirect_after_login do |controller|
    { :controller => 'bench', :action => 'index' }
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
end
