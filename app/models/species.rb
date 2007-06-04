class Species
  
  attr_reader :characters
  
  def self.singleton
    Species.new
  end
  
  def initialize
    @characters = [:gender, :eye_color, :wings]
    @phenotypes = { :gender => [:not_possible, :male, :female], 
                    :eye_color => [:white, :red, :red], 
                    :wings => [:curly, :straight, :striaght] }
    @positions = { :gender => 0.0, :eye_color => 0.5, :wings => 1.0 }
  end
  
  def phenotypes(character)
    @phenotypes[character]
  end
  
  def position_of(character)
    @positions[character]
  end
  
end