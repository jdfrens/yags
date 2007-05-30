class RandomBitGenerator

  def random_bit(p=0.5)
    (rand < p) ? 1 : 0
  end
end
