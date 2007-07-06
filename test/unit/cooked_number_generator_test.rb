require File.dirname(__FILE__) + '/../test_helper'

class CookedNumberGeneratorTest < Test::Unit::TestCase
  
  def test_random_number
    # the UK emergency phone number:
    numbers = [0,1,1,8,9,9,9,8,8,1,9,9,9,1,1,9,7,2,5,3]
    generator = CookedNumberGenerator.new(numbers)
    numbers.each do |number|
      assert_equal number, generator.random_number
    end
  end
  
  def test_random_number_wraps
    numbers = [1,2,4,8,3]
    generator = CookedNumberGenerator.new(numbers)
    numbers.each do |number|
      assert_equal number, generator.random_number
    end
    numbers.each do |number|
      assert_equal number, generator.random_number
    end
    
    numbers = [0]
    generator = CookedNumberGenerator.new(numbers)
    sum = 0
    947.times do
      sum = sum + generator.random_number
    end
    assert_equal 0, sum
  end
  
  def test_received_ns
    generator = CookedNumberGenerator.new([0])
    generator.random_number(5)
    generator.random_number(4)
    generator.random_number(3)
    generator.random_number(8)
    assert_equal [5, 4, 3, 8], generator.received_ns
    generator.random_number(7)
    assert_equal [5, 4, 3, 8, 7], generator.received_ns
    assert_equal [8, 7], generator.received_ns[3..-1]
  end
end
