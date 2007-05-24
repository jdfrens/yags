class BenchController < ApplicationController

  def collect_field_vial
    vial = Vial.create!(:label => "field vial")
    1.upto(8) do |i|
      vial.flies << Fly.create!(:locus_mom => 1, :locus_dad => 0)
      vial.save!
    end
    redirect_to :action => "view_vial", :id => vial.id
  end

  def view_vial
  end
end
