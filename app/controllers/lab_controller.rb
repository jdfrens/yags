class LabController < ApplicationController
  restrict_to :manage_lab, :only => [ :index, :list_courses, :add_course, :view_course,
                                      :delete_course, :list_scenarios, :add_scenario, :delete_scenario,
                                      :view_scenario, :view_cheat_sheet, :choose_course_scenarios, :view_student_vial,
                                      :update_student_solutions_table, :update_student_table ]

  def index
  end

  #
  # Courses
  #

  # FIXME: this should be removed
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
    @course = Course.find(params[:id])
    if @course && @course.instructor == current_user
      @students = @course.students
    else
      redirect_to :action => "list_courses"
    end
  end

  def delete_course
    if params[:id] && Course.find_by_id(params[:id]) &&
            Course.find(params[:id]).instructor == current_user
      Course.find(params[:id]).destroy
    end
    redirect_to(instructor_courses_path)
  end

  #
  # Vials? Courses?
  #
  def update_student_solutions_table
    if params[:id] && Course.find_by_id(params[:id]) &&
            Course.find(params[:id]).instructor == current_user
      course = Course.find(params[:id])
      @students = course.students
      render :update do |page|
        page.replace_html 'table_of_student_solutions', :partial => 'student_solutions_table'
      end
    else
      redirect_to :action => 'list_courses'
    end
  end

  #
  # Scenarios
  #
  def choose_course_scenarios
    if params[:id] and @course = Course.find_by_id(params[:id]) and current_user == @course.instructor
      @scenarios = Scenario.find(:all)
      if request.post?
        @course.scenarios.clear
        params[:scenario_ids].each do |scenario_id|
          @course.scenarios << Scenario.find_by_id(scenario_id)
        end
        redirect_to :action => :view_course, :id => @course.id
      end
    else
      redirect_to :action => "index"
    end
  end

  def list_scenarios
    case params[:id]
      when "your"
        @scenarios = current_user.owned_scenarios
        @howmany = "your"
      when "all"
        @scenarios = Scenario.find(:all)
        @howmany = "all"
      else
        redirect_to :action => "list_scenarios", :id => "all"
    end
  end

  def add_scenario
    @species = Species.singleton
    @characters = @species.characters
    @courses = current_user.instructs
    if request.post? && params[:scenario] && params[:characters] && params[:courses]
      @scenario = Scenario.new params[:scenario]
      @scenario.owner = current_user
      @scenario.save!
      @characters.each do |character|
        if !params[:characters].include?(character.to_s)
          ScenarioPreference.create!(:scenario_id => @scenario.id, :hidden_character => character.to_s)
        elsif params[:alternates] and params[:alternates].include?(character.to_s)
          RenamedCharacter.create!(:scenario_id => @scenario.id, :renamed_character => character.to_s)
        end
      end
      @courses.each do |course|
        if params[:courses].map { |c| c.to_i }.include?(course.id)
          course.scenarios << @scenario
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
    if params[:id] && Scenario.find_by_id(params[:id]) &&
            Scenario.find(params[:id]).owner == current_user
      Scenario.find(params[:id]).destroy
    end
    redirect_to :action => "list_scenarios"
  end

  #
  # ?????
  #
  def view_cheat_sheet
    @species = Species.singleton
    @species_name = "YAGS Fruit Fly"
    @characters = []
    @species.characters.each do |character|
      @characters << {
              :name => character.to_s,
              :hom_dom => @species.phenotype_from(character, 1, 1).to_s,
              :het => @species.phenotype_from(character, 1, 0).to_s,
              :rec => @species.phenotype_from(character, 0, 0).to_s,
              :location => @species.position_of(@species.gene_number_of(character)),
              :sex_linked => @species.sex_linked?(character) ? "yes" : "no",
              :randomizable => @species.alternate_phenotypes(character) != [] ? "yes" : "no" }
    end
  end

  #
  # Vials
  #
  def view_student_vial
    if (params[:id] && @vial = Vial.find_by_id(params[:id])) &&
            (current_user.instructs.include?(@vial.owner.enrolled_in))
      @visible_characters = @vial.owner.current_scenario.visible_characters
      @parents = [@vial.mom, @vial.dad]
      @table = @vial.owner.row && @vial.owner.column
      if @table
        @row_character = @vial.owner.row.intern
        @column_character = @vial.owner.column.intern
        @row_phenotypes = @vial.phenotypes_for_table(@row_character)
        @column_phenotypes = @vial.phenotypes_for_table(@column_character)
        @counts = @vial.counts_for_table(@row_character, @column_character)
      end
    else
      redirect_to :action => 'list_courses'
    end
  end

  def update_student_table
    must_use_xhr_post
    @vial = Vial.find(params[:vial_id])
    if @vial.owner.owns?(@vial) && (current_user.instructs.include?(@vial.owner.enrolled_in))
      @column_character = params[:character_col].intern
      @row_character = params[:character_row].intern
      @column_phenotypes = @vial.phenotypes_for_table(@column_character)
      @row_phenotypes = @vial.phenotypes_for_table(@row_character)
      @counts = @vial.counts_for_table(@row_character, @column_character)
    else
      raise InvalidOwner
    end
  rescue InvalidHttpMethod, InvalidOwner
    render :nothing => true, :status => 401
  end

end
