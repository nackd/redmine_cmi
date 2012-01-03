class AddGroupToCmiProjectInfos < ActiveRecord::Migration
  def self.up
    add_column :cmi_project_infos, :group, :text, :null => false
  end

  def self.down
    remove_column :cmi_project_infos, :group
  end
end
