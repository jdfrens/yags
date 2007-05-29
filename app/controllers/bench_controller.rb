class BenchController < ApplicationController
  
  def collect_field_vial
    if (params[:vial])
      vial = Vial.create!(params[:vial])
      create_and_add_field_flies vial
      redirect_to :action => "view_vial", :id => vial.id
    end
  end
  
  def view_vial
    @vial = Vial.find(params[:id])    
  end
  
  def list_vials
    @vials = Vial.find(:all)
    #@vials_pages, @vials = paginate :vials, :per_page => 10
  end
  
  #
  # Helpers
  #
  private
  
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
