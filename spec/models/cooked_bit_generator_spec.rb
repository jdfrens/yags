require File.dirname(__FILE__) + '/../spec_helper'

class CookedBitGeneratorTest < ActiveSupport::TestCase
  
  def test_random_bit
    bits = [0, 1, 0, 1, 0, 0, 0, 1]
    generator = CookedBitGenerator.new(bits)
    bits.each do |bit|
      assert_equal bit, generator.random_bit
    end
  end
  
  def test_random_bit_wraps
    bits = [0, 1, 1, 1, 0, 0, 1, 1]
    generator = CookedBitGenerator.new(bits)
    bits.each do |bit|
      assert_equal bit, generator.random_bit
    end
    bits.each do |bit|
      assert_equal bit, generator.random_bit
    end
    
    bits = [0]
    generator = CookedBitGenerator.new(bits)
    sum = 0
    1000.times do
      sum = sum + generator.random_bit
    end
    assert_equal 0, sum
  end
  
  def test_received_ps
    generator = CookedBitGenerator.new([0])
    generator.random_bit(0.2)
    generator.random_bit(0.3)
    generator.random_bit(0.4)
    generator.random_bit(0.1)
    assert_equal [0.2, 0.3, 0.4, 0.1], generator.received_ps
    generator.random_bit(0.999)
    generator.random_bit(0.14159)
    assert_equal [0.2, 0.3, 0.4, 0.1, 0.999, 0.14159], generator.received_ps
    assert_equal [0.2, 0.3, 0.4, 0.1], generator.received_ps[0..3]
    assert_equal [0.1, 0.999, 0.14159], generator.received_ps[-3..-1]
  end
end
