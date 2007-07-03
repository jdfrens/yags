class AddRealNamesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    
    User.find(:all).each do |user|
      user.first_name = user.username
      user.last_name = user.username
      user.save!
    end
  end

  def self.down
    remove_column :users, :first_name
    remove_column :users, :last_name
  end
end
