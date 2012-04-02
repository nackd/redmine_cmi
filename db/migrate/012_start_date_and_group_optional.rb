class StartDateAndGroupOptional < ActiveRecord::Migration
  def self.up
    change_column :cmi_project_infos, :group, :string, :null => true
    change_column :cmi_project_infos, :actual_start_date, :date, :null => true
  end

  def self.down
    change_column :cmi_project_infos, :group, :text, :null => false
    change_column :cmi_project_infos, :actual_start_date, :date, :null => false
  end
end
