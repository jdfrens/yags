require "erb"
  include ERB::Util

class BenchController < ApplicationController
  in_place_edit_for :vial, :label
  
  def collect_field_vial
    if (params[:vial])
      vial = Vial.collect_from_field(params[:vial], params[:number].to_i)
      redirect_to :action => "view_vial", :id => vial.id
    end
  end
  
  def mate_flies
    if (params[:vial])
      vial = Vial.make_babies_and_vial(params[:vial], params[:number].to_i)
      redirect_to :action => "view_vial", :id => vial.id
    end
  end
  
  def view_vial
    @vial = Vial.find(params[:id])
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
  end
  
  def view_fly
    @fly = Fly.find(params[:id])    
  end
  
  def list_vials
    @vials = Vial.find(:all)
  end
  
  def destroy_vial
    @vial = Vial.find(params[:id]).destroy
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
        @column_titles = @vial.species.phenotypes(@columns).uniq
        @column_titles.delete(:not_possible) # not elegant
        @row_titles = @vial.species.phenotypes(@rows).uniq
        @row_titles.delete(:not_possible)    # not elegant
      end
      redirect_to :action => "view_vial", :id => @vial unless request.xhr?
  end

end