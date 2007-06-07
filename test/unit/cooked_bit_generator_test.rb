require File.dirname(__FILE__) + '/../test_helper'

class CookedBitGeneratorTest < Test::Unit::TestCase

  def test_random_bit
    bits = [0, 1, 0, 1, 0, 0, 0, 1]
    generator = CookedBitGenerator.new(bits)
    bits.each do |bit|
      assert_equal bit, generator.random_bit
    end
  end

  def test_random_bit_uses_parameter
    ps = [0, 0.2, 0.4, 0.5, 0.6, 0.8, 1.0]
    generator = CookedBitGenerator.new(ps)
    
    answers = [0,0,0,0,0,0,1]
    answers.each do |bit|
      assert_equal bit, generator.random_bit(0.9)
    end
    
    answers = [0,0,0,0,1,1,1]
    answers.each do |bit|
      assert_equal bit, generator.random_bit(0.6)
    end
    
    answers = [0,0,0,1,1,1,1]
    answers.each do |bit|
      assert_equal bit, generator.random_bit(0.5)
    end
    
    answers = [0,1,1,1,1,1,1]
    answers.each do |bit|
      assert_equal bit, generator.random_bit(0.2)
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
end
