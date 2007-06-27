class RenameCharacterToHiddenCharacterAgain < ActiveRecord::Migration
  def self.up
    # gah! i'm frustrated that i have to write this one...
    execute "ALTER TABLE scenario_preferences CHANGE `character` hidden_character varchar(255)"
  end

  def self.down
    execute "ALTER TABLE scenario_preferences CHANGE hidden_character `character` varchar(255)"
  end
end
