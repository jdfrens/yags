class LabController < ApplicationController

  restrict_to :manage_lab, :only => [ :index, :list_courses, :add_course, :view_course, 
      :delete_course, :list_scenarios, :add_scenario, :delete_scenario, :view_scenario ]

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
    if params[:id] and Course.find_by_id(params[:id]) and 
        Course.find(params[:id]).instructor == current_user
      @course = Course.find(params[:id])
      @students = @course.students
      @solutions = Solution.find(:all)
    else
      redirect_to :action => "list_courses"
    end
  end
  
  def delete_course
    if params[:id] and Course.find_by_id(params[:id]) and 
        Course.find(params[:id]).instructor == current_user
      Course.find(params[:id]).destroy
    end
    redirect_to :action => "list_courses"
  end
  
  def list_scenarios
    @scenarios = Scenario.find(:all)
  end
  
  def add_scenario
    @characters = Species.singleton.characters
    if request.post? and params[:scenario]
      @scenario = Scenario.new params[:scenario]
      @scenario.save!
      species = Species.singleton # the selected species later
      species.characters.each do |character|
        unless params.keys.include?(character.to_s) and params[character.to_s]
          ScenarioPreference.create!(:scenario_id => @scenario.id, :hidden_character => character.to_s)
        end
      end
      redirect_to :action => "list_scenarios"
    else
      render
    end
    rescue ActiveRecord::RecordInvalid
    render
  end
  
  def view_scenario
    if params[:id] and Scenario.find_by_id(params[:id])
      @scenario = Scenario.find(params[:id])
    else
      redirect_to :action => "list_scenarios"
    end
  end
  
  def delete_scenario
    if params[:id] and Scenario.find_by_id(params[:id])
      Scenario.find(params[:id]).destroy
    end
    redirect_to :action => "list_scenarios"
  end

end
