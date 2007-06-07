class CookedBitGenerator

  def initialize(bits)
    @bits = bits
    @ps = []
    @counter = -1
  end
  
  def random_bit(p=0.5)
    @ps << p
    @counter = (@counter + 1) % @bits.length
    @bits[@counter]
  end
  
  def received_ps
    @ps
  end

end
