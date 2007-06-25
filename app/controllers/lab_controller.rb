class LabController < ApplicationController

  restrict_to :manage_lab, :only => [ :index ]

  def index 
    @username = current_user.username
  end

end
