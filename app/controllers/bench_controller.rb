require "erb"
  include ERB::Util

class BenchController < ApplicationController
  in_place_edit_for :vial, :label
  
  restrict_to :manage_bench
  
  def index
    @username = current_user.username
  end
  
  def collect_field_vial
    if (params[:vial])
      params[:vial][:user_id] = current_user.id
      vial = Vial.collect_from_field(params[:vial], params[:number].to_i)
      redirect_to :action => "view_vial", :id => vial.id
    end
  end
  
  def mate_flies
    vials = Vial.find(:all, :conditions => "user_id = #{current_user.id}" )
    @vial_labels_and_ids = []
    vials.each do |vial|
      @vial_labels_and_ids << [vial.label, vial.id]
    end
    if (params[:vial])
      if Fly.find(params[:vial][:mom_id]).vial.user_id == current_user.id and 
          Fly.find(params[:vial][:dad_id]).vial.user_id == current_user.id
        params[:vial][:user_id] = current_user.id
        vial = Vial.make_babies_and_vial(params[:vial], params[:number].to_i)
        redirect_to :action => "view_vial", :id => vial.id
      else
        redirect_to :action => "list_vials"
      end
    end
  end
  
  def show_mateable_flies
    if request.post?
      @vial = Vial.find(params[:vial])
    end
    @phenotypes_to_flies = {}
    @vial.combinations_of_phenotypes.each do |combination|
      @phenotypes_to_flies[combination] = @vial.flies_of_type @vial.species.characters, combination
    end
    @which_vial = params[:which_vial]
    redirect_to :action => "mate_flies" unless request.xhr? 
  end
  
  def view_vial
    @vial = Vial.find(params[:id])
    if @vial.user_id == current_user.id
      if @vial.mom_id && @vial.dad_id
        @parents = true
        @mom = Fly.find @vial.mom_id
        @dad = Fly.find @vial.dad_id
        @mom_vial = Vial.find @mom.vial_id
        @dad_vial = Vial.find @dad.vial_id
      else
        @parents = false
      end
      @column_titles = @vial.species.phenotypes(:gender)
      @row_titles = @vial.species.phenotypes(:gender)
      @phenotypes_to_flies = {}
      @vial.combinations_of_phenotypes.each do |combination|
        @phenotypes_to_flies[combination] = @vial.flies_of_type @vial.species.characters, combination
      end
    else
      redirect_to :action => "list_vials"
    end
  end
  
  def view_fly
    @fly = Fly.find(params[:id])    
  end
  
  def list_vials
    @vials = Vial.find(:all, :conditions => "user_id = #{current_user.id}" )
    @all_vials = Vial.find(:all)
  end
  
  # future: confirm deletetion of vial
  def destroy_vial
    if params[:id] && request.post?
      Vial.find(params[:id]).destroy      
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

  def update_table
      if request.post?
        @vial = Vial.find(params[:vial_id])
        @columns = params[:character_col].intern
        @rows = params[:character_row].intern
        @column_titles = @vial.species.phenotypes(@columns)
        @row_titles = @vial.species.phenotypes(@rows)
      end
      redirect_to :action => "view_vial", :id => @vial unless request.xhr?
  end
  
end