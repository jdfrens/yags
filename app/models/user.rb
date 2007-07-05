class User < ActiveRecord::Base
  
  acts_as_login_model
  
  has_many :racks, :dependent => :destroy
  has_many :vials, :through => :racks
  has_many :character_preferences, :dependent => :destroy
  has_one  :basic_preference, :dependent => :destroy
  has_many :phenotype_alternates, :dependent => :destroy
  has_many :instructs, :class_name => "Course", :foreign_key => "instructor_id", :dependent => :destroy
  belongs_to :enrolled_in, :class_name => "Course", :foreign_key => "course_id"
  
  def solutions
    Solution.find_all_by_vial_id(vials.map { |v| v.id })
  end
  
  def hidden_characters
    if self.current_scenario
      character_preferences.map { |p| p.hidden_character.intern } + current_scenario.hidden_characters
    else
      character_preferences.map { |p| p.hidden_character.intern }
    end
  end
  
  def visible_characters(characters = Species.singleton.characters)
    characters - hidden_characters
  end
  
  def visible?(character)
    # this seems like not the best way to do
    visible_characters.include? character
  end
  
  def instructor?
    group.name == "instructor"
  end
  
  def students
    if instructor?
      instructs.map { |c| c.students }.flatten
    else
     []
    end
  end
  
  def has_authority_over(other_user)
    if group.name == "admin" or self == other_user or students.include?(other_user)
      true
    else
      false
    end
  end
  
  # i wish we could generate these next two methods.  but i didn't know how
  def current_scenario
    if self.group.name == "student" and self.basic_preference
      Scenario.find_by_id basic_preference.scenario_id
      # change if a basic_preference belongs_to :senario relationship is set up
    else
      nil
    end
  end
  
  # hmm, the other method ^ doesn't have "_id" in it's name...
  def current_scenario_id=(new_id)
    if self.basic_preference
      self.basic_preference.scenario_id = new_id
      self.basic_preference.save!
    else
      new_bp = BasicPreference.new(:user_id => self.id, :scenario_id => new_id)
      new_bp.save!
    end
  end
  
end
