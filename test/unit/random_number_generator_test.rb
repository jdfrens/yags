require File.dirname(__FILE__) + '/../test_helper'

class RandomNumberGeneratorTest < ActiveSupport::TestCase
  
  def test_random_number
    generator = RandomNumberGenerator.new
    1.upto(21) do
      assert generator.random_number(7) >= 0 and generator.random_number(7) < 7
    end
  end
  
end
