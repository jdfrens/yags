require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../app/models/array_extensions'

class ArrayExtensionsTest < Test::Unit::TestCase

  def test_zup
    [].zup([]) do |x, y|
      fail "shouldn't be here!"
    end

    [].zup([1]) do |x, y|
      assert_nil x
      assert_equal 1, y
    end

    [:a].zup([]) do |x, y|
      assert_equal :a, x
      assert_nil y
    end
    
    xs = []
    ys = []
    [1, 2, 3].zup([:a, :b, :c]) do |x, y|
      xs << x
      ys << y
    end
    assert_equal [1, 2, 3], xs
    assert_equal [:a, :b, :c], ys
  end

end
