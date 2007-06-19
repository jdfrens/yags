class CreateCharacterPreferences < ActiveRecord::Migration
  def self.up
    create_table :character_preferences do |t|
      t.column :user_id,   :integer
      t.column :character, :string
    end
  end

  def self.down
    drop_table :character_preferences
  end
end
