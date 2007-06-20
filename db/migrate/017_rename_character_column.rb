class RenameCharacterColumn < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE character_preferences CHANGE `character` hidden_character varchar(255)"
  end

  def self.down
    execute "ALTER TABLE character_preferences CHANGE hidden_character `character` varchar(255)"
  end
end
