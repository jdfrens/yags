class RenameCharacterToHiddenCharacterAgain < ActiveRecord::Migration
  def self.up
    rename_column :scenario_preferences, :character, :hidden_character
  end

  def self.down
    rename_column :scenario_preferences, :hidden_character, :character
  end
end
