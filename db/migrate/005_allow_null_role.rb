class AllowNullRole < ActiveRecord::Migration
  def self.up
    change_column :time_entries, :role, :string, :null => true
  end

  def self.down
    change_column :time_entries, :role, :string, :null => false
  end
end
