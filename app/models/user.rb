class User < ActiveRecord::Base
  
  acts_as_login_model
  
  has_many :vials
  has_many :character_preferences
  has_one  :basic_preference 
  
  def hidden_characters
    character_preferences.map { |p| p.hidden_character.intern }
  end
  
  def visible_characters(characters = Species.singleton.characters)
    characters - (hidden_characters + [:crazy_value_that_is_always_ignored])
  end
  
end
