
class CreateHistoryUserProfiles < ActiveRecord::Migration
  def self.up
    create_table :history_user_profiles, :force => true do |t|
      t.column :user_id, :integer, :null => false
      t.column :profile, :string, :limit => 20, :null => false
      t.column :created_on, :datetime, :null => false
      t.column :finished_on, :datetime, :null => true
      t.column :hour_cost, :float, :null => false
    end
  end

  def self.down
    drop_table :history_user_profiles
  end
end
