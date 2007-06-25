class User < ActiveRecord::Base
  
  acts_as_login_model
  
  has_many :racks
  has_many :character_preferences
  has_one  :basic_preference 
  has_many :courses, :foreign_key => "instructor_id"
  
  def hidden_characters
    character_preferences.map { |p| p.hidden_character.intern }
  end
  
  def visible_characters(characters = Species.singleton.characters)
    characters - (hidden_characters + [:crazy_value_that_is_always_ignored])
  end
  
  def vials
    racks.map { |r| r.vials }.flatten
  end
  
end
