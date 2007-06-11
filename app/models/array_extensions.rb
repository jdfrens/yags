class Array
  
  def zup(other)
    self.zip(other) do |pair|
      yield(pair[0], pair[1])
    end
  end
  
end