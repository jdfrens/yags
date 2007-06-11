# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require File.dirname(__FILE__) + '/../models/array_extensions'

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_YAGS_session_id'
end
