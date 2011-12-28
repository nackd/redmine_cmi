module CMI
  class ProjectMetrics < Metrics
    unloadable

    def initialize(project)
      @project = project.is_a?(Project) ? project : Project.find(project)
      @checkpoint = @project.cmi_checkpoints.find(:first,
                                                  :order => 'checkpoint_date DESC')
      @date = Date.today
    end

    def time_scheduled
      (checkpoint.scheduled_finish_date - project.cmi_project_info.actual_start_date).to_i
    end

    def time_remaining
      if !project.cmi_project_info.actual_start_date.nil?
        (checkpoint.scheduled_finish_date - date - 1).to_i
      else
        "--"
      end
    end

    def total_income
      project.cmi_project_info.total_income
    end

    def executed
      if total_cost_scheduled.zero?
        0.0
      else
        100.0 * (hhrr_cost_incurred + material_cost_scheduled) / total_cost_scheduled
      end
    end

    def to_s
      # TODO translate this
      "Valor actual - #{date}"
    end

    private

    def held_qa_meetings
      checkpoint.held_qa_meetings
    end
  end
end
