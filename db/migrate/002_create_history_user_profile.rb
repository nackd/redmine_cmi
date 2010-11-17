
class CreateHistoryUserProfile < ActiveRecord::Migration
  def self.up
    create_table :history_user_profiles, :force => true do |t|
      t.column :user_id, :integer
      t.column :profile, :string, :limit => 20, :default => "", :null => false
      t.column :created_on, :datetime, :null => false
      t.column :finished_on, :datetime, :null => true
      t.column :hour_cost, :float, :default => 0.0, :null => "0.0"
    end
  end

  def self.down
    drop_table :history_user_profiles
  end
end
