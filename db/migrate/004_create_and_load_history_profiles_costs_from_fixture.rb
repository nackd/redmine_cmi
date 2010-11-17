require 'active_record/fixtures'

class CreateAndLoadHistoryProfilesCostsFromFixture < ActiveRecord::Migration
  def self.up
    create_table :history_profiles_costs, :force => true do |t|
      t.column :profile, :string, :limit => 20, :default => "", :null => false
      t.column :year, :integer, :null => false
      t.column :value, :float, :null => false
    end
    Fixtures.create_fixtures("#{File.dirname(__FILE__)}/../fixtures", 'history_profiles_costs')
  end

  def self.down
    drop_table :history_profiles_costs
  end
end
