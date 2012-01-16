class AddCostAndRoleToTimeEntry < ActiveRecord::Migration
  def self.up
    add_column :time_entries, :cost, :float, :default => 0.0, :null => true
    add_column :time_entries, :role, :string, :null => false
  end

  def self.down
    remove_column :time_entries, :cost
    remove_column :time_entries, :role
  end
end
