# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require File.dirname(__FILE__) + '/../models/array_extensions'

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_YAGS_session_id'
  
  filter_parameter_logging "password"
  
  class InvalidAccess < RuntimeError 
  end
  
  #
  # Helpers
  #
  private
   
  # this is so that we don't have to live on the edge
  # can (should!) remove after upgrading to Rails 2
  # needed for LWT Authentication
  def authenticate_with_http_basic
    nil
  end
        
end
