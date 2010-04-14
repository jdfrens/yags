class Instructor::CoursesController < ApplicationController

  restrict_to :manage_lab
  on_not_logged_in do
    redirect_to login_path
    false
  end

  def index
    @courses = current_user.instructs
  end

  def new
    @course = Course.new
  end

  def create
    params[:course][:instructor_id] = current_user.id
    @course = Course.create!(params[:course])
    redirect_to(instructor_courses_path)
  end  
end
