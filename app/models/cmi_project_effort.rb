class CmiProjectEffort < ActiveRecord::Base
  unloadable

  belongs_to :cmi_project_info, :inverse_of => :cmi_project_efforts

  validates_presence_of :cmi_project_info, :role, :scheduled_effort
  validates_numericality_of :scheduled_effort
end
