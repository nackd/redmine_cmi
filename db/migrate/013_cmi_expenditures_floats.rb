class CmiExpendituresFloats < ActiveRecord::Migration
  def self.up
    change_column :cmi_expenditures, :initial_budget, :decimal, :precision => 12, :scale => 2, :null => false
    change_column :cmi_expenditures, :current_budget, :decimal, :precision => 12, :scale => 2, :null => false
    change_column :cmi_expenditures, :incurred,       :decimal, :precision => 12, :scale => 2, :null => false, :default => 0.0
  end

  def self.down
    change_column :cmi_expenditures, :initial_budget, :integer, :null => false
    change_column :cmi_expenditures, :current_budget, :integer, :null => false
    change_column :cmi_expenditures, :incurred,       :integer, :null => false, :default => 0
  end
end
