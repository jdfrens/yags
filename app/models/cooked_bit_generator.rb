class CookedBitGenerator

  def initialize(bits)
    @bits = bits
    @counter = -1
  end
  
  def random_bit(p=0.5)
    @counter = (@counter + 1) % @bits.length
    @bits[@counter]
  end
end
