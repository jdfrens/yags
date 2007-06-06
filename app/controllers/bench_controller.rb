require "erb"
  include ERB::Util

class BenchController < ApplicationController
  in_place_edit_for :vial, :label
  
  def collect_field_vial
    if (params[:vial])
#      vial = Vial.create!(params[:vial])
      vial = Vial.collect_from_field(params[:vial], params[:number].to_i)
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
  
  def mate_flies
    if (params[:vial])
      vial = Vial.create!(params[:vial])
      populate_vial_with_children(vial, params[:number].to_i)
      redirect_to :action => "view_vial", :id => vial.id
    end
  end
  
  def set_vial_label
    @vial = Vial.find(params[:id])
    previous_label = @vial.label
    @vial.label = params[:value]
    @vial.label = previous_label unless @vial.save
    render :text => h(@vial.label)
  end
  
  #
  # Helpers
  #
  private
  
  def populate_vial_with_children(vial, number)
    mom = Fly.find vial.mom_id
    dad = Fly.find vial.dad_id
    number.times do |i|
      vial.flies << mom.mate_with(dad)
      vial.save!
    end
  end
  
end