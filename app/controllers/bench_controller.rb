require "erb"
include ERB::Util

class BenchController < ApplicationController
  in_place_edit_for :vial, :label
  in_place_edit_for :rack, :label
  restrict_to :manage_bench
  
  def index; end
  
  def preferences
    @user = current_user
    if current_user.current_scenario
      @characters = current_user.current_scenario.visible_characters
    else
      @characters = Species.singleton.characters
    end
    if request.post?
      @characters.each do |character|
        if params[character] == "visible"
          CharacterPreference.find(:all, :conditions => 
              "user_id = #{current_user.id} AND hidden_character = \'#{character}\'").each { |p| p.destroy }
        else 
          if !current_user.hidden_characters.include?(character)
            CharacterPreference.create!(:user_id => current_user.id, :hidden_character => character.to_s)
          end
        end
      end
      redirect_to :action => "index"
    end
  end
  
  def choose_scenario
    if current_user.current_scenario
      @current_scenario_title = current_user.current_scenario.title
    else
      @current_scenario_title = "None Selected"
    end
    @scenario_titles_and_ids = []
    current_user.enrolled_in.scenarios.each do |scenario|
      @scenario_titles_and_ids << [scenario.title, scenario.id]
    end
    if request.post?
      if @scenario_titles_and_ids.map { |d| d[1] }.include? params[:scenario_id].to_i
        current_user.set_scenario_to params[:scenario_id].to_i
      end
      redirect_to :action => "index"
    end
  end
  
  def collect_field_vial
    if (params[:vial])
      # TODO: why isn't this a dropdown in the form?
      params[:vial][:rack_id] = current_user.racks.first.id
      @vial = Vial.collect_from_field(params[:vial])
      @vial.save!
      redirect_to :action => "view_vial", :id => @vial.id
    else
      render
    end
    rescue ActiveRecord::RecordInvalid
    render
  end
  
  def mate_flies
    @vial_labels_and_ids = []
    current_user.vials.each do |vial|
      @vial_labels_and_ids << [vial.label, vial.id]
    end
    @rack_labels_and_ids = []
    current_user.racks.each do |rack|
      @rack_labels_and_ids << [rack.label, rack.id]
    end
    if params[:vial]
      @vial = Vial.make_babies_and_vial(params[:vial].merge({ :creator => current_user }))
      @vial.save!
      redirect_to :action => "view_vial", :id => @vial.id
    else
      render
    end
    rescue ActiveRecord::RecordInvalid
    render
  end
  
  def show_mateable_flies
    if request.post?
      @vial = Vial.find(params[:vial])
      # TODO: why isn't @vial nil below sometimes?
    end
    @phenotypes_to_flies = {}
    @vial.combinations_of_phenotypes(current_user.visible_characters).each do |combination|
      @phenotypes_to_flies[combination] = @vial.flies_of_type(current_user.visible_characters, combination)
    end
    @which_vial = params[:which_vial]
    redirect_to :action => "mate_flies" unless request.xhr? 
    # TODO: what if it's not xhr?
  end
  
  def view_vial
    if valid_vial_to_view?
      @vial = Vial.find_by_id(params[:id])
      @visible_characters = current_user.visible_characters
      # TODO: no assignments in condition!!!!!!!
      if @table = (current_user.basic_preference && 
            current_user.basic_preference.row && current_user.basic_preference.column)
        @row_character = current_user.basic_preference.row.intern
        @column_character = current_user.basic_preference.column.intern
        @row_phenotypes = @vial.phenotypes_for_table(@row_character)
        @column_phenotypes = @vial.phenotypes_for_table(@column_character)
        @counts = @vial.counts_for_table(@row_character, @column_character)
      end
    else
      redirect_to :action => "list_vials"
    end
  end
  
  def list_vials
    @racks = current_user.racks
  end
  
  def destroy_vial
    if params[:id] && request.post?
      vial = Vial.find(params[:id])
      if current_user.owns?(vial)
        vial.destroy
        flash[:notice] = "#{vial.label} has been deleted"
      else
        flash[:notice] = "You do not own that vial."
      end
    end
    redirect_to :action => :list_vials
  end
  
  def set_vial_label
    @vial = Vial.find(params[:id])
    previous_label = @vial.label
    @vial.label = params[:value]
    @vial.label = previous_label unless @vial.save
    render :text => h(@vial.label)
  end
  
  def set_rack_label
    @rack = Rack.find(params[:id])
    previous_label = @rack.label
    @rack.label = params[:value]
    @rack.label = previous_label unless @rack.save
    render :text => h(@rack.label)
  end
  
  def set_as_solution
    if request.post?
      @old_solution = find_old_solution(params[:solution])
      if @old_solution
        @old_solution.update_attributes(params[:solution])
      else
        @solution = Solution.new params[:solution]
        @solution.save!
      end
      render
    else
      render :nothing => true
    end
    rescue ActiveRecord::RecordInvalid
    render
  end
  
  def update_table
    if request.post?
      @vial = Vial.find(params[:vial_id])
      @column_character = params[:character_col].intern
      @row_character = params[:character_row].intern
      @column_phenotypes = @vial.phenotypes_for_table(@column_character)
      @row_phenotypes = @vial.phenotypes_for_table(@row_character)
      @counts = @vial.counts_for_table(@row_character, @column_character)
      if current_user.basic_preference.nil?
        BasicPreference.create!(:user_id => current_user.id, :row => @row_character.to_s, :column => @column_character.to_s)
      else
        current_user.basic_preference.row = @row_character.to_s
        current_user.basic_preference.column = @column_character.to_s
        current_user.basic_preference.save!
      end
    end
    redirect_to :action => "view_vial", :id => @vial unless request.xhr?
  end
  
  def update_parent_div
    @fly = params[:id]
    @sex = params[:sex]
  end
  
  def add_rack
    if params[:rack]
      params[:rack][:user_id] = current_user.id
      @rack = Rack.new params[:rack]
      @rack.save!
      redirect_to :action => "list_vials"
    else
      render
    end
    rescue ActiveRecord::RecordInvalid
    render
  end
  
  def move_vial_to_another_rack
    @vial = Vial.find(params[:id])
    @rack_labels_and_ids = []
    current_user.racks.each do |rack|
      @rack_labels_and_ids << [rack.label, rack.id]
    end
    if request.post?
      rack = Rack.find(params[:rack_id])
      if current_user.owns?(@vial) and current_user.owns?(rack)
        @vial.rack = rack
        @vial.save!
        redirect_to :action => "view_vial", :id => @vial.id
      else
        # flash[:notice] = "Action failed - bad parameters" # or something
        redirect_to :action => "list_vials"
      end
    end
  end

  #
  # Helpers
  #
  private

  def find_old_solution(options)
    number = options[:number].to_i
    vial_id = options[:vial_id].to_i
    old_solution = current_user.solutions.find do |solution|
      solution.number == number || solution.vial_id == vial_id
    end
  end
  
  def valid_vial_to_view?
    params[:id] && Vial.find_by_id(params[:id]) && current_user.owns?(Vial.find(params[:id]))
  end
  
end
