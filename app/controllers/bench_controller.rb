class BenchController < ApplicationController
  
  def collect_field_vial
    vial = Vial.create!(:label => "field vial")
    [0, 1].each do |mom_allele|
      [0, 1].each do |dad_allele|
        vial.flies << Fly.create!(:locus_mom => mom_allele, :locus_dad => dad_allele)
        vial.save!
      end
    end
    
    redirect_to :action => "view_vial", :id => vial.id
  end
  
  def view_vial
    @vial = Vial.find(params[:id])    
  end
end
