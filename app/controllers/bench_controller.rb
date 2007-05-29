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
  end
  
  def list_vials
    @vials = Vial.find(:all)
    #@vials_pages, @vials = paginate :vials, :per_page => 10
  end
  
  #
  # Helpers
  #
  private
  
  def create_and_add_many_field_flies(vial, number)
    mom_alleles = [0, 0, 1, 1, 0]
    dad_alleles = [1, 0, 1, 0]
    number.downto(1) do |i|
      vial.flies << Fly.create!(:locus_mom => mom_alleles[i % 5], :locus_dad => dad_alleles[i % 4])
      vial.save!
    end
  end
  
end