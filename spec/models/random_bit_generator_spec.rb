require File.dirname(__FILE__) + '/../spec_helper'

class RandomBitGeneratorTest < ActiveSupport::TestCase
  
  def test_random_bit
    counts = generate_random_bits(5000)
    # these tests should fail with probability less than 4 * 10^-5
    assert_greater_than counts[0], 2500 - 4 * standard_error_for_count(5000,0.5)
    assert_greater_than counts[1], 2500 - 4 * standard_error_for_count(5000,0.5)
    assert_total 5000, counts
  end
  
  def test_random_bit_with_extreme_parameters
    counts = generate_random_bits(1000, 0)
    assert_equal 1000, counts[0]
    assert_equal    0, counts[1]    
    assert_total 1000, counts
    
    counts = generate_random_bits(1000, 1)
    assert_equal    0, counts[0]
    assert_equal 1000, counts[1]
    assert_total 1000, counts 
  end
  
  def test_random_bit_with_typical_parameters
    counts = generate_random_bits(5000, 0.2)
    # these tests should fail with probability less than 4 * 10^-5
    assert_greater_than counts[0], 5000 * 0.8 - 4 * standard_error_for_count(5000,0.2)
    assert_greater_than counts[1], 5000 * 0.2 - 4 * standard_error_for_count(5000,0.2)
    assert_total 5000, counts
    
    counts = generate_random_bits(5000, 0.9)
    # these tests should fail with probability less than 4 * 10^-5
    assert_greater_than counts[0],  0.1 * 5000 - 4 * standard_error_for_count(5000,0.9)
    assert_greater_than counts[1],  0.9 * 5000 - 4 * standard_error_for_count(5000,0.9)
    assert_total 5000, counts
  end
  
  # 
  # Helper
  #
  def generate_random_bits(count=1000, p=0.5)
    generator = RandomBitGenerator.new
    counts = [0, 0]
    count.times do
      counts[generator.random_bit(p)] += 1
    end    
    counts
  end
  
  def assert_greater_than(actual, expected)
    assert_block "expected something greater than #{expected}, but got #{actual}" do
      expected < actual
    end
  end
  
  def assert_total(expected, actual)
    assert_equal expected, actual[0] + actual[1],
        "expected #{expected} bits in all, only counted #{actual[0] + actual[1]}"
  end
  
  def standard_error_for_count(n,p)
    Math.sqrt(p * (1-p) * n)
  end
  
end
