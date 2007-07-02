class ChangeGenderToSexInDatabase < ActiveRecord::Migration
  def self.up
    BasicPreference.find(:all).each do |bp|
      bp.column = "sex" if bp.column == "gender"
      bp.row = "sex" if bp.row == "gender"
      bp.save!
    end
    
    CharacterPreference.find(:all).each do |cp|
      cp.hidden_character = "sex" if cp.hidden_character == "gender"
      cp.save!
    end
    
    ScenarioPreference.find(:all).each do |sp|
      sp.hidden_character = "sex" if sp.hidden_character == "gender"
      sp.save!
    end
  end

  def self.down
    BasicPreference.find(:all).each do |bp|
      bp.column = "gender" if bp.column == "sex"
      bp.row = "gender" if bp.row == "sex"
      bp.save!
    end
    
    CharacterPreference.find(:all).each do |cp|
      cp.hidden_character = "gender" if cp.hidden_character == "sex"
      cp.save!
    end
    
    ScenarioPreference.find(:all).each do |sp|
      sp.hidden_character = "gender" if sp.hidden_character == "sex"
      sp.save!
    end
  end
end
