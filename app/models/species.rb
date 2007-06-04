class Species

  @@singleton = Species.new
  
  def self.singleton
    @@singleton
  end
  
end