class Instructor::CoursesController < ApplicationController

  restrict_to :manage_lab
  on_not_logged_in do
    redirect_to login_path
    false
  end

  def index
    @courses = current_user.instructs
  end

  def show
    @course = Course.find(params[:id])
    if @course && @course.instructor == current_user
      @students = @course.students
    else
      redirect_to(instructor_courses_path)
    end
  end

  def update_student_solutions_table
    if params[:id] && Course.find_by_id(params[:id]) &&
            Course.find(params[:id]).instructor == current_user
      course = Course.find(params[:id])
      @students = course.students
      render :update do |page|
        page.replace_html 'table_of_student_solutions', :partial => 'student_solutions_table'
      end
    else
      redirect_to(instructor_courses_path)
    end
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
