require "erb"
include ERB::Util

class BenchController < ApplicationController
  in_place_edit_for :vial, :label
  
  restrict_to :manage_bench
  
  def index
  end
  
  def preferences
    @user = current_user
    if current_user.current_scenario
      @characters = current_user.current_scenario.visible_characters
    else
      @characters = Species.singleton.characters
      # it would be nice if every user had a basic_preference...
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
    @scenario_titles_and_ids = [["None", nil]]
    Scenario.find(:all).each do |scenario|
      @scenario_titles_and_ids << [scenario.title, scenario.id]
    end
    if request.post? and params[:scenario_id]
      current_user.current_scenario_id = params[:scenario_id]
      redirect_to :action => "index"
    end
  end
  
  def collect_field_vial
    if (params[:vial])
      params[:vial][:rack_id] = current_user.racks.first.id
      @vial = Vial.collect_from_field(params[:vial], params[:number].to_i)
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
      if Fly.find(params[:vial][:mom_id]).vial.user_id == current_user.id and 
        Fly.find(params[:vial][:dad_id]).vial.user_id == current_user.id
        params[:vial][:rack_id] = params[:rack_id]
        @vial = Vial.make_babies_and_vial(params[:vial], params[:number].to_i)
        @vial.save!
        redirect_to :action => "view_vial", :id => @vial.id
      else
        redirect_to :action => "list_vials"
      end
    end
    rescue ActiveRecord::RecordInvalid
    render
  end
  
  def show_mateable_flies
    if request.post?
      @vial = Vial.find(params[:vial])
    end
    @phenotypes_to_flies = {}
    @vial.combinations_of_phenotypes(current_user.visible_characters).each do |combination|
      @phenotypes_to_flies[combination] = @vial.flies_of_type(current_user.visible_characters, combination)
    end
    @which_vial = params[:which_vial]
    redirect_to :action => "mate_flies" unless request.xhr? 
  end
  
  def view_vial
    if params[:id] and @vial = Vial.find_by_id(params[:id]) and @vial.user_id == current_user.id
      @rack = Rack.find(@vial.rack_id)
      if @parents = (@vial.mom_id && @vial.dad_id)
        @mom, @dad = Fly.find(@vial.mom_id), Fly.find(@vial.dad_id)
        @mom_vial = Vial.find @mom.vial_id
        @dad_vial = Vial.find @dad.vial_id
      end
      if @table = current_user.basic_preference
        @rows = current_user.basic_preference.row.intern
        @columns = current_user.basic_preference.column.intern
      end
      @row_titles = @vial.species.phenotypes(@rows)
      @column_titles = @vial.species.phenotypes(@columns)
      @visible_characters = current_user.visible_characters
      @solution_vial = Solution.find(:all)
    else
      redirect_to :action => "list_vials"
    end
  end
  
  def list_vials
    @racks = current_user.racks
    @vials = current_user.vials
  end
  
  def destroy_vial
    if params[:id] && request.post?
      @vial = Vial.find(params[:id]).destroy      
    end
    flash[:notice] = "#{@vial.label} has been deleted"
    redirect_to :action => :list_vials
  end
  
  def set_vial_label
    @vial = Vial.find(params[:id])
    previous_label = @vial.label
    @vial.label = params[:value]
    @vial.label = previous_label unless @vial.save
    render :text => h(@vial.label)
  end
  
  def set_as_solution
    if request.post?
      solution = Solution.new params[:solutions]
      solution.save!
    else
      render
    end
    rescue ActiveRecord::RecordInvalid
    render
  end
  
  def update_table
    if request.post?
      @vial = Vial.find(params[:vial_id])
      @columns = params[:character_col].intern
      @rows = params[:character_row].intern
      @column_titles = @vial.species.phenotypes(@columns)
      @row_titles = @vial.species.phenotypes(@rows)
      if current_user.basic_preference.nil?
        BasicPreference.create!(:user_id => current_user.id, :row => @rows.to_s, :column => @columns.to_s)
      else
        current_user.basic_preference.row = @rows.to_s
        current_user.basic_preference.column = @columns.to_s
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
      if @vial.user == current_user and current_user.racks.include? Rack.find(params[:rack_id])
        @vial.rack_id = params[:rack_id]
        @vial.save!
        redirect_to :action => "view_vial", :id => @vial.id
      else
        # flash[:notice] = "Action failed - bad parameters" # or something
        redirect_to :action => "list_vials"
      end
    end
  end
  
end