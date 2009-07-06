require File.dirname(__FILE__) + '/../spec_helper'

class CartesianProductTest < ActiveSupport::TestCase

  include CartesianProduct
  
  def test_cartesian_product_handles_empty_input
    assert_equal [[]], cartesian_product([])
  end
  
  def test_cartesian_product_handles_single_factor
    factor = [['A','B','C']]
    assert_equal [['A'],['B'],['C']], cartesian_product(factor)
  end
  
  def test_cartesian_product
    factor1 = ['a','b','c']
    factor2 = [1,2,3,4]
    factor3 = [5,6]
    result12 = [
      ['a',1],['a',2],['a',3], ['a',4],      
      ['b',1],['b',2],['b',3], ['b',4],
      ['c',1],['c',2],['c',3], ['c',4],
    ]
    
    result312 = [   
      [5,'a',1],[5,'a',2],[5,'a',3], [5,'a',4],      
      [5,'b',1],[5,'b',2],[5,'b',3], [5,'b',4],
      [5,'c',1],[5,'c',2],[5,'c',3], [5,'c',4],
      [6,'a',1],[6,'a',2],[6,'a',3], [6,'a',4],      
      [6,'b',1],[6,'b',2],[6,'b',3], [6,'b',4],
      [6,'c',1],[6,'c',2],[6,'c',3], [6,'c',4],
    ]
    assert_equal result12, cartesian_product([factor1,factor2])
    assert_equal result312, cartesian_product([factor3,factor1,factor2])
  end
  
end
