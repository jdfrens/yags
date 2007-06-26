class LabController < ApplicationController

  restrict_to :manage_lab, :only => [ :index, :list_courses, :add_course, :view_course ]

  def index 
    @username = current_user.username
  end
  
  def list_courses
    @courses = current_user.courses
  end
  
  def add_course
    if params[:course]
      params[:course][:instructor_id] = current_user.id
      @course = Course.new params[:course]
      @course.save!
      redirect_to :action => "list_courses"
    else
      render
    end
    rescue ActiveRecord::RecordInvalid
    render
  end
  
  def view_course
    if params[:id] and Course.find_by_id(params[:id]) and Course.find(params[:id]).instructor == current_user
      @course = Course.find(params[:id])
      @students = @course.students
    else
      redirect_to :action => "list_courses"
    end
  end

end
