require File.dirname(__FILE__) + '/../test_helper'

class RandomBitGeneratorTest < Test::Unit::TestCase
  
  def test_random_bit
    counts = generate_random_bits(5000)
    # these tests should fail with probability less than 4 * 10^-5
    assert_greater_than counts[0], 2500 - 4 * standard_error_for_count(5000,0.5)
    
    assert_greater_than counts[1], 2500 - 4 * standard_error_for_count(5000,0.5)
    assert_equal 5000, counts[0] + counts[1]

  end
  
  def test_random_bit_with_extreme_parameters
    counts = generate_random_bits(1000, 0)
    assert_equal 1000, counts[0]
    assert_equal 0, counts[1]    
    
    counts = generate_random_bits(1000, 1)
    assert_equal 0, counts[0]
    assert_equal 1000, counts[1]
  end
  
  def test_random_bit_with_typical_parameters
    counts = generate_random_bits(5000, 0.2)
    # these tests should fail with probability less than 4 * 10^-5
    assert_greater_than counts[0], 5000 * 0.8 - 4 * standard_error_for_count(5000,0.2)
    assert_greater_than counts[1], 5000 * 0.2 - 4 * standard_error_for_count(5000,0.2)
    assert_equal 5000, counts[0] + counts[1]
    
    counts = generate_random_bits(5000, 0.9)
    # these tests should fail with probability less than 4 * 10^-5
    assert_greater_than counts[0],  0.1 * 5000 - 4 * standard_error_for_count(5000,0.9)
    assert_greater_than counts[1],  0.9 * 5000 - 4 * standard_error_for_count(5000,0.9)
    assert_equal 5000, counts[0] + counts[1]

  end
  
  # 
  # Helper
  #
  def generate_random_bits(count=1000, p=0.5)
    generator = RandomBitGenerator.new
    counts = [0, 0]
    1.upto(count) do |i|
      bit = generator.random_bit(p)
      assert_block "should be 0 or 1" do
        bit == 0 || bit == 1
      end
      counts[bit] += 1
    end    
    counts
  end
  
  def assert_greater_than(actual, expected)
    assert_block "expected something greater than #{expected}, but got #{actual}" do
      expected < actual
    end
  end
  
  def standard_error_for_count(n,p)
    Math.sqrt(p * (1-p) * n)
  end
  
end
