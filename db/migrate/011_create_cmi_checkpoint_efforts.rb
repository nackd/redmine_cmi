class CreateCmiCheckpointEfforts < ActiveRecord::Migration
  class ::CmiCheckpoint < ActiveRecord::Base
    serialize :scheduled_role_effort, Hash
    has_many :cmi_checkpoint_efforts, :dependent => :destroy
  end

  def self.up
    create_table :cmi_checkpoint_efforts do |t|
      t.references :cmi_checkpoint, :null => false
      t.string :role, :null => false
      t.float :scheduled_effort, :null => false, :default => 0
      t.timestamps
    end

    add_index :cmi_checkpoint_efforts, [:cmi_checkpoint_id, :role], :unique => true

    CmiCheckpointEffort.reset_column_information
    CmiCheckpointEffort.transaction do
      begin
        CmiCheckpoint.find_each(:batch_size => 50) do |checkpoint|
          checkpoint.scheduled_role_effort.each_pair do |role, effort|
            CmiCheckpointEffort.create! :cmi_checkpoint => checkpoint,
                                        :role => role,
                                        :scheduled_effort => effort
          end
        end
      rescue
        drop_table :cmi_checkpoint_efforts
        raise
      end
    end

    remove_column :cmi_checkpoints, :scheduled_role_effort
  end

  def self.down
    add_column :cmi_checkpoints, :scheduled_role_effort, :text

    CmiCheckpoint.reset_column_information
    CmiCheckpoint.transaction do
      begin
        CmiCheckpoint.find_each(:batch_size => 50) do |checkpoint|
          checkpoint.scheduled_role_effort = {}
          checkpoint.cmi_checkpoint_efforts.each do |effort|
            checkpoint.scheduled_role_effort[effort.role] = effort.scheduled_effort
            effort.destroy
          end
          checkpoint.save!
        end
      rescue
        remove_column :cmi_checkpoints, :scheduled_role_effort
        raise
      end
    end

    drop_table :cmi_checkpoint_efforts
  end
end
