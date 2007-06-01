class BenchController < ApplicationController
  
  def collect_field_vial
    if (params[:vial])
      vial = Vial.create!(params[:vial])
      create_and_add_many_field_flies(vial, params[:number].to_i)
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
  end
  
  def view_fly
    @fly = Fly.find(params[:id])    
  end
  
  def list_vials
    @vials = Vial.find(:all)
  end
  
  def mate_flies
    if (params[:vial])
      vial = Vial.create!(params[:vial])
      create_and_add_many_field_flies(vial, params[:number].to_i)
      redirect_to :action => "view_vial", :id => vial.id
    end
  end
  
  #
  # Helpers
  #
  private
  
  def create_and_add_many_field_flies(vial, number)
    mom_alleles = [0, 0, 1, 1, 0]
    dad_alleles = [1, 0, 1, 0]
    sex_alleles = [1, 0, 1, 1, 0, 1, 0]
    number.times do |i|
       new_fly = Fly.create!
       new_fly.genotypes << Genotype.create!(:fly_id => new_fly.id, :position => 0.5, 
           :mom_allele => mom_alleles[i % 5], :dad_allele => dad_alleles[i % 4])
       new_fly.genotypes << Genotype.create!(:fly_id => new_fly.id, :position => 0.0, 
           :mom_allele => 1, :dad_allele => sex_alleles[i % 4])
       vial.flies << new_fly
       vial.save!
    end
  end
  
end