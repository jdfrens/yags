class Instructor::CoursesController < ApplicationController

  restrict_to :manage_lab

  def index
    @courses = current_user.instructs
  end
end
