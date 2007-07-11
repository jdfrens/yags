class Scenario < ActiveRecord::Base
  has_many :scenario_preferences, :dependent => :destroy
  has_many :renamed_characters, :dependent => :destroy
  
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
  
  def has_renamed?(character)
    renamed_characters.select { |rc| rc.renamed_character.intern == character }.size != 0
  end
  
end
