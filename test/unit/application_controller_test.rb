require File.dirname(__FILE__) + '/../test_helper'

class ApplicationControllerTest < Test::Unit::TestCase

  def setup
    @app = ApplicationController.new
  end
  
  def test_authenticate_with_http_basic
    assert_nil @app.authenticate_with_http_basic
  end
  
end
