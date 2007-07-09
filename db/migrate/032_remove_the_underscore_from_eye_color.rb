class RemoveTheUnderscoreFromEyeColor < ActiveRecord::Migration
  def self.up
    BasicPreference.find(:all).each do |bp|
      bp.column = "eye color" if bp.column == "eye_color"
      bp.row = "eye color" if bp.row == "eye_color"
      bp.save!
    end
    
    CharacterPreference.find(:all).each do |cp|
      cp.hidden_character = "eye color" if cp.hidden_character == "eye_color"
      cp.save!
    end
    
    ScenarioPreference.find(:all).each do |sp|
      sp.hidden_character = "eye color" if sp.hidden_character == "eye_color"
      sp.save!
    end
    
    PhenotypeAlternate.find(:all).each do |pa|
      pa.affected_character = "eye color" if pa.affected_character == "eye_color"
      pa.save!
    end
    
    RenamedCharacter.find(:all).each do |rc|
      rc.renamed_character = "eye color" if rc.renamed_character == "eye_color"
      rc.save!
    end
  end

  def self.down
    BasicPreference.find(:all).each do |bp|
      bp.column = "eye_color" if bp.column == "eye color"
      bp.row = "eye_color" if bp.row == "eye color"
      bp.save!
    end
    
    CharacterPreference.find(:all).each do |cp|
      cp.hidden_character = "eye_color" if cp.hidden_character == "eye color"
      cp.save!
    end
    
    ScenarioPreference.find(:all).each do |sp|
      sp.hidden_character = "eye_color" if sp.hidden_character == "eye color"
      sp.save!
    end
    
    PhenotypeAlternate.find(:all).each do |pa|
      pa.affected_character = "eye_color" if pa.affected_character == "eye color"
      pa.save!
    end
    
    RenamedCharacter.find(:all).each do |rc|
      rc.renamed_character = "eye_color" if rc.renamed_character == "eye color"
      rc.save!
    end
  end
end
