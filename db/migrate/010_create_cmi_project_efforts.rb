class CreateCmiProjectEfforts < ActiveRecord::Migration
  class ::CmiProjectInfo < ActiveRecord::Base
    serialize :scheduled_role_effort, Hash
    has_many :cmi_project_efforts, :dependent => :destroy
  end

  def self.up
    create_table :cmi_project_efforts do |t|
      t.references :cmi_project_info, :null => false
      t.string :role, :null => false
      t.float :scheduled_effort, :null => false, :default => 0
      t.timestamps
    end

    add_index :cmi_project_efforts, [:cmi_project_info_id, :role], :unique => true

    CmiProjectEffort.reset_column_information
    CmiProjectEffort.transaction do
      begin
        CmiProjectInfo.find_each(:batch_size => 50) do |info|
          info.scheduled_role_effort.each_pair do |role, effort|
            CmiProjectEffort.create! :cmi_project_info => info,
                                     :role => role,
                                     :scheduled_effort => effort
          end
        end
      rescue
        drop_table :cmi_project_efforts
        raise
      end
    end

    remove_column :cmi_project_infos, :scheduled_role_effort
  end

  def self.down
    add_column :cmi_project_infos, :scheduled_role_effort, :text

    CmiProjectInfo.reset_column_information
    CmiProjectInfo.transaction do
      begin
        CmiProjectInfo.find_each(:batch_size => 50) do |info|
          info.scheduled_role_effort = {}
          info.cmi_project_efforts.each do |effort|
            info.scheduled_role_effort[effort.role] = effort.scheduled_effort
            effort.destroy
          end
          info.save!
        end
      rescue
        remove_column :cmi_project_infos, :scheduled_role_effort
        raise
      end
    end

    drop_table :cmi_project_efforts
  end
end
