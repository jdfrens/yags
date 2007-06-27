class User < ActiveRecord::Base
  
  acts_as_login_model
  
  has_many :racks, :dependent => :destroy
  has_many :character_preferences, :dependent => :destroy
  has_one  :basic_preference, :dependent => :destroy
  has_many :courses, :foreign_key => "instructor_id", :dependent => :destroy
  belongs_to :course # this scares me because the above is only one letter different.
                     # they are used in different places...
                     # but still, should we go witout this last belongs_to line?
  
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
