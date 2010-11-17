require 'active_record/fixtures'

class CreateHistoryProfilesCosts < ActiveRecord::Migration
  def self.up
    create_table :history_profiles_costs, :force => true do |t|
      t.column :profile, :string, :limit => 20, :null => false
      t.column :year, :integer, :null => false
      t.column :value, :float, :null => false
    end
  end

  def self.down
    drop_table :history_profiles_costs
  end
end
