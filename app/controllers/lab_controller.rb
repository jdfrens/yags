class LabController < ApplicationController
  restrict_to :manage_lab, :only => [ :index, :list_courses, :add_course, :view_course, 
  :delete_course, :list_scenarios, :add_scenario, :delete_scenario, :view_scenario,
  :view_cheat_sheet, :choose_course_scenarios ]
  
  def index 
    @username = current_user.username
  end
  
  def list_courses
    @courses = current_user.instructs
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
    else
      redirect_to :action => "list_courses"
    end
  end
  
  def choose_course_scenarios
    if params[:id] and @course = Course.find_by_id(params[:id]) and current_user == @course.instructor
      @scenarios = Scenario.find(:all)
      if request.post?
        @course.scenarios.each { |s| @course.scenarios.delete s }
        params[:scenario_ids].each do |scenario_id|
          @course.scenarios << Scenario.find_by_id(scenario_id)
        end
        redirect_to :action => :view_course, :id => @course.id
      end
    else
      redirect_to :action => "index"
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
    @species = Species.singleton # the selected species later
    @characters = Species.singleton.characters
    if request.post? and params[:scenario] and params[:characters] and params[:alternates]
      @scenario = Scenario.new params[:scenario]
      @scenario.save!
      @species.characters.each do |character|
        unless params[:characters].include?(character.to_s)
          ScenarioPreference.create!(:scenario_id => @scenario.id, :hidden_character => character.to_s)
        end
        if params[:alternates].include?(character.to_s)
          RenamedCharacter.create!(:scenario_id => @scenario.id, :renamed_character => character.to_s)
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
  
  def view_cheat_sheet
    @species = Species.singleton
    @species_name = "Virtual Fruit Fly"
    # later that should be chosen in a drop down list or something
    @characters = [] 
    @species.characters.each do |character|
      @characters << {:name => character.to_s, :hom_dom => @species.phenotype_from(character, 1,1).to_s, 
        :het => @species.phenotype_from(character, 1,0).to_s, :rec => @species.phenotype_from(character, 0,0).to_s,
        :location => @species.position_of(@species.gene_number_of(character)) }
      # use .map instead?
    end
  end
  
  def view_student_vial
    if params[:id] && @vial = Vial.find_by_id(params[:id])
      @rack = Rack.find(@vial.rack_id)
      if @parents = (@vial.mom_id && @vial.dad_id)
        @mom, @dad = Fly.find(@vial.mom_id), Fly.find(@vial.dad_id)
        @mom_vial = Vial.find @mom.vial_id
        @dad_vial = Vial.find @dad.vial_id
      end
      @visible_characters = current_user.visible_characters
    else
      redirect_to :action => 'view_course'
    end
  end
  
end
