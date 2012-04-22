class CmiCheckpointEffort < ActiveRecord::Base
  unloadable

  belongs_to :cmi_checkpoint, :inverse_of => :cmi_checkpoint_efforts

  validates_presence_of :cmi_checkpoint, :role, :scheduled_effort
  validates_numericality_of :scheduled_effort
end
