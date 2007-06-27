class Scenario < ActiveRecord::Base
  has_many :scenario_preferences, :dependent => :destroy
  
  def hidden_characters
    scenario_preferences.map { |p| p.hidden_character.intern }
  end
  
  def visible_characters
    species = Species.singleton # later it will know it's own species??
    species.characters - hidden_characters
  end
end
