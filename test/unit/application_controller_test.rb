require File.dirname(__FILE__) + '/../test_helper'

class ApplicationControllerTest < Test::Unit::TestCase

  def setup
    @app = ApplicationController.new
  end
  
  def test_number_is_valid
    assert  @app.number_valid?('123')
    assert  @app.number_valid?('66')
    assert !@app.number_valid?('-12')
    assert !@app.number_valid?('22445')
    
    assert !@app.number_valid?('-1')
    assert  @app.number_valid?('0')
    assert  @app.number_valid?('255')
    assert !@app.number_valid?('256')
    
    assert !@app.number_valid?('sfx')
    assert !@app.number_valid?('12x')
    assert !@app.number_valid?('y44')
  end
 
end
