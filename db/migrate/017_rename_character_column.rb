class RenameCharacterColumn < ActiveRecord::Migration
  def self.up
    rename_column :character_preferences, :character, :hidden_character
  end

  def self.down
    rename_column :character_preferences, :hidden_character, :character
  end
end
