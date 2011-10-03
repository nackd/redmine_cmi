module CMI
  class CheckpointMetrics
    unloadable

    def initialize(checkpoint)
      @checkpoint = checkpoint
      @project = checkpoint.project
      # TODO get rid of the yesterday thing
      @date = checkpoint.checkpoint_date.yesterday
    end

    def effort_done
      User.roles.inject(0.0) { |sum, role| sum + effort_done_by_role(role) }
    end

    def effort_done_by_role(role)
      @project.effort_done_by_role(role, @date)
    end

    def effort_scheduled
      User.roles.inject(0.0) { |sum, role| sum + effort_scheduled_by_role(role) }
    end

    def effort_scheduled_by_role(role)
      @checkpoint.scheduled_role_effort[role]
    end

    def effort_remaining
      User.roles.inject(0.0) { |sum, role| sum + effort_remaining_by_role(role) }
    end

    def effort_remaining_by_role(role)
      effort_scheduled_by_role(role) - effort_done_by_role(role)
    end

    def effort_percent_done_by_role(role)
      if  effort_scheduled_by_role(role).zero?
        0.0
      else
        100.0 * effort_done_by_role(role) / effort_scheduled_by_role(role)
      end
    end

    def effort_percent_done
      if  effort_scheduled.zero?
        0.0
      else
        100.0 * effort_done / effort_scheduled
      end
    end

    def time_done
      if !@project.cmi_project_info.actual_start_date.nil?
          (@date - @project.cmi_project_info.actual_start_date + 1).to_i
      else
          "--"
      end
    end

    def time_scheduled
      (scheduled_finish_date - @project.cmi_project_info.actual_start_date).to_i
    end

    def time_remaining
      (scheduled_finish_date - @date - 1).to_i
    end

    def time_percent_done
      if  time_scheduled.zero?
        0.0
      else
        100.0 * time_done / time_scheduled
      end
    end

    def hhrr_cost_incurred
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['spent_on <= ?', @date]
      TimeEntry.sum(:cost,
                    :joins => :project,
                    :conditions => cond.conditions)
    end

    def hhrr_cost_scheduled
      User.roles.inject(0) { |sum, role|
        sum += (@checkpoint.scheduled_role_effort[role] *
                HistoryProfilesCost.find(:first, :conditions => ['profile = ? AND year = ?', role, @date.year]).value)
      }
    end

    def hhrr_cost_original
      User.roles.inject(0) { |sum, role|
        sum += (@project.cmi_project_info.scheduled_role_effort[role] *
                HistoryProfilesCost.find(:first, :conditions => ['profile = ? AND year = ?', role, Date.today.year]).value)
      }
    end

    def hhrr_cost_remaining
      hhrr_cost_scheduled - hhrr_cost_incurred
    end

    def hhrr_cost_percent_incurred
      if hhrr_cost_scheduled.zero?
        0.0
      else
        100.0 * hhrr_cost_incurred / hhrr_cost_scheduled
      end
    end

    def hhrr_cost_percent
      if total_cost_scheduled.zero?
        0.0
      else
        100.0 * hhrr_cost_scheduled / total_cost_scheduled
      end
    end

    def material_cost_incurred
      @project.cmi_expenditures.sum(:incurred)
    end

    def material_cost_scheduled
      @project.cmi_expenditures.sum(:current_budget)
    end

    def material_cost_remaining
      material_cost_scheduled - material_cost_incurred
    end

    def material_cost_percent_incurred
      if material_cost_scheduled.zero?
        0.0
      else
        100.0 * material_cost_incurred / material_cost_scheduled
      end
    end

    def material_cost_percent
      if total_cost_scheduled.zero?
        0.0
      else
        100.0 * material_cost_scheduled / total_cost_scheduled
      end
    end

    def material_cost_original
      @project.cmi_expenditures.sum(:initial_budget)
    end

    def total_cost_incurred
      hhrr_cost_incurred + material_cost_incurred
    end

    def total_cost_scheduled
      hhrr_cost_scheduled + material_cost_scheduled
    end

    def total_cost_remaining
      total_cost_scheduled - total_cost_incurred
    end

    def total_cost_percent_incurred
      if total_cost_scheduled.zero?
        0.0
      else
        100.0 * total_cost_incurred / total_cost_scheduled
      end
    end

    def total_cost_original
      hhrr_cost_original + material_cost_original
    end

    def original_margin
      @project.cmi_project_info.total_income - total_cost_original
    end

    def original_margin_percent
      100.0 * original_margin / @project.cmi_project_info.total_income
    end

    def scheduled_margin
      @project.cmi_project_info.total_income - total_cost_scheduled
    end

    def scheduled_margin_percent
      100.0 * scheduled_margin / @project.cmi_project_info.total_income
    end

    def incurred_margin
      @project.cmi_project_info.total_income - total_cost_incurred
    end

    def incurred_margin_percent
      100.0 * incurred_margin / @project.cmi_project_info.total_income
    end

    def to_s
      checkpoint_date.to_s
    end

    private

    def method_missing(method, *args, &block)
      @checkpoint.send method, *args, &block
    end
  end
end
