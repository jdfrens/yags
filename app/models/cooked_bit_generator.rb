class CookedBitGenerator

  def initialize(probs)
    @probs = probs
    @counter = -1
  end
  
  def random_bit(p=0.5)
    @counter = (@counter + 1) % @probs.length
    (@probs[@counter] < p ? 0 : 1)
  end
  
end
