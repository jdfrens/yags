class BenchController < ApplicationController
  
  def collect_field_vial
    if (params[:vial])
      vial = Vial.create!(params[:vial])
      create_and_add_field_flies vial
      #create_and_add_so_many_flies vial, params[:vial][:number]
      redirect_to :action => "view_vial", :id => vial.id
    end
  end
  
  def view_vial
    @vial = Vial.find(params[:id])    
  end
  
  #
  # Helpers
  #
  private
  
  #  def create_and_add_so_many_flies(vial, number)
  #    mom_allele = 1
  #    dad_allele = 1
  #    until vial.flies.size >= number do
  #      vial.flies << Fly.create!(:locus_mom => mom_allele, :locus_dad => dad_allele)
  #        vial.save!
  #    end
  #  end
  
  def create_and_add_many_field_flies(vial)
    mom_allele = 1
    dad_allele = 1
    4.downto(1) do 
      vial.flies << Fly.create!(:locus_mom => mom_allele, :locus_dad => dad_allele)
      vial.save!
    end
  end
  
  def create_and_add_field_flies(vial)
    [0, 1].each do |mom_allele|
      [0, 1].each do |dad_allele|
        vial.flies << Fly.create!(:locus_mom => mom_allele, :locus_dad => dad_allele)
        vial.save!
      end
    end
  end
  
end