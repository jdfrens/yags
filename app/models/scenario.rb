class Scenario < ActiveRecord::Base
  has_many :scenario_preferences, :dependent => :destroy
  has_many :renamed_characters, :dependent => :destroy # needs to be tested
  
  def hidden_characters
    scenario_preferences.map { |p| p.hidden_character.intern }
  end
  
  def visible_characters
    species.characters - hidden_characters
  end
  
  # not tested
  def species
    Species.singleton
  end
  
end
