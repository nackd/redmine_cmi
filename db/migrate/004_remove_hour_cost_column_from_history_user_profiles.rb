class RemoveHourCostColumnFromHistoryUserProfiles < ActiveRecord::Migration
  def self.up
    remove_column :history_user_profiles, :hour_cost
  end

  def self.down
    add_column :history_user_profiles, :hour_cost, :float, :null => false
  end
end
