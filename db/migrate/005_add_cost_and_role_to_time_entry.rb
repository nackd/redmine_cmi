class AddCostAndRoleToTimeEntry < ActiveRecord::Migration
  def self.up
    add_column :time_entries, :cost, :float, :default => "0.0", :null => "0.0"
    add_column :time_entries, :role, :string, :default => "PS", :null => "PS"
  end

  def self.down
    remove_column :time_entries, :cost
    remove_column :time_entries, :role
  end
end


