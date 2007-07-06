class CookedNumberGenerator

  def initialize(numbers)
    @numbers = numbers
    @ns = []
    @counter = -1
  end
  
  def random_number(n=1)
    @ns << n
    @counter = (@counter + 1) % @numbers.length
    @numbers[@counter]
  end
  
  def received_ns
    @ns
  end

end
