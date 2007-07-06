class CreateRenamedCharacters < ActiveRecord::Migration
  def self.up
    create_table :renamed_characters do |t|
      t.column :scenario_id,       :integer
      t.column :renamed_character, :string
    end
  end

  def self.down
    drop_table :renamed_characters
  end
end
