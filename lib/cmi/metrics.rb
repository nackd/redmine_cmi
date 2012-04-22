module CMI
  class Metrics
    unloadable

    attr_reader :checkpoint, :date, :project

    def effort_done
      User.roles.inject(0.0) { |sum, role| sum + effort_done_by_role(role) }
    end

    def effort_done_by_role(role)
      project.effort_done_by_role(role, date)
    end

    def effort_scheduled
      User.roles.inject(0.0) { |sum, role| sum + effort_scheduled_by_role(role) }
    end

    def effort_scheduled_by_role(role)
      checkpoint.scheduled_role_effort[role].to_f
    end

    def effort_remaining
      User.roles.inject(0.0) { |sum, role| sum + effort_remaining_by_role(role) }
    end

    def effort_remaining_by_role(role)
      effort_scheduled_by_role(role) - effort_done_by_role(role)
    end

    def effort_percent_done_by_role(role)
      if effort_scheduled_by_role(role).zero?
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

    def effort_original_by_role(role)
      project.cmi_project_info.scheduled_role_effort(role)
    end

    def effort_original
      User.roles.inject(0.0) { |sum, role| sum + effort_original_by_role(role) }
    end

    def effort_deviation_percent
      if effort_original.zero?
        0.0
      else
        100.0 * (effort_scheduled - effort_original) / effort_original
      end
    end

    def conf_effort_incurred
      cond = [ project.project_condition(Setting.display_subprojects_issues?) <<
               ' AND (spent_on <= ?)' <<
               ' AND (issue_categories.name = ?)',
               date, Setting.plugin_redmine_cmi['conf_category'] ]
      TimeEntry.sum(:hours,
                    :joins => [:project, {:issue => :category} ],
                    :conditions => cond)
    end

    def conf_effort_percent
      if effort_done.zero?
        0.0
      else
        100.0 * conf_effort_incurred / effort_done
      end
    end

    def time_done
      if !project.cmi_project_info.actual_start_date.nil?
        (date - project.cmi_project_info.actual_start_date + 1).to_i
      else
        "--"
      end
    end

    def time_percent_done
      if  time_scheduled.zero?
        0.0
      else
        100.0 * time_done / time_scheduled
      end
    end

    def time_original
      project.cmi_project_info.scheduled_finish_date - project.cmi_project_info.scheduled_start_date
    end

    def time_deviation_percent
      100.0 * (time_scheduled - time_original) / time_original
    end

    def hhrr_cost_incurred
      cond = [ project.project_condition(Setting.display_subprojects_issues?) <<
               ' AND (spent_on <= ?)',
               date ]
      TimeEntry.sum(:cost,
                    :joins => :project,
                    :conditions => cond)
    end

    def hhrr_cost_scheduled
      User.roles.inject(0) { |sum, role|
        sum += (checkpoint.nil? ?
                0 :
                checkpoint.scheduled_role_effort[role] *
                HistoryProfilesCost.find(:first, :conditions => ['profile = ? AND year = ?', role, date.year]).value)
      }
    end

    def hhrr_cost_original
      User.roles.inject(0) { |sum, role|
        sum += (project.cmi_project_info.scheduled_role_effort(role) *
                HistoryProfilesCost.find(:first,
                                         :conditions => ['profile = ? AND year = ?', role, project.cmi_project_info.scheduled_start_date.year]).value)
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
      project.cmi_expenditures.sum(:incurred)
    end

    def material_cost_scheduled
      project.cmi_expenditures.sum(:current_budget)
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
      project.cmi_expenditures.sum(:initial_budget)
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

    def total_cost_deviation
      total_cost_scheduled - total_cost_original
    end

    def total_cost_deviation_percent
      100.0 * total_cost_deviation / total_cost_original
    end

    def original_margin
      project.cmi_project_info.total_income - total_cost_original
    end

    def original_margin_percent
      100.0 * original_margin / project.cmi_project_info.total_income
    end

    def scheduled_margin
      project.cmi_project_info.total_income - total_cost_scheduled
    end

    def scheduled_margin_percent
      100.0 * scheduled_margin / project.cmi_project_info.total_income
    end

    def incurred_margin
      project.cmi_project_info.total_income - total_cost_incurred
    end

    def incurred_margin_percent
      100.0 * incurred_margin / project.cmi_project_info.total_income
    end

    def risk_low
      cond = [ project.project_condition(Setting.display_subprojects_issues?) <<
               ' AND (start_date <= ?)' <<
               ' AND (tracker_id = ?)' <<
               ' AND (priority_id in (?))',
               date, Setting.plugin_redmine_cmi['risks_tracker'], Setting.plugin_redmine_cmi['priority_low'] ]
      Issue.count :joins => :project, :conditions => cond
    end

    def risk_medium
      cond = [ project.project_condition(Setting.display_subprojects_issues?) <<
               ' AND (start_date <= ?)' <<
               ' AND (tracker_id = ?)' <<
               ' AND (priority_id in (?))',
               date, Setting.plugin_redmine_cmi['risks_tracker'], Setting.plugin_redmine_cmi['priority_medium'] ]
      Issue.count :joins => :project, :conditions => cond
    end

    def risk_high
      cond = [ project.project_condition(Setting.display_subprojects_issues?) <<
               ' AND (start_date <= ?)' <<
               ' AND (tracker_id = ?)' <<
               ' AND (priority_id in (?))',
               date, Setting.plugin_redmine_cmi['risks_tracker'], Setting.plugin_redmine_cmi['priority_high'] ]
      Issue.count :joins => :project, :conditions => cond
    end

    def risk_total
      cond = [ project.project_condition(Setting.display_subprojects_issues?) <<
               ' AND (start_date <= ?)' <<
               ' AND (tracker_id = ?)',
               date, Setting.plugin_redmine_cmi['risks_tracker'] ]
      Issue.count :joins => :project, :conditions => cond
    end

    def incident_low
      cond = [ project.project_condition(Setting.display_subprojects_issues?) <<
               ' AND (start_date <= ?)' <<
               ' AND (tracker_id = ?)' <<
               ' AND (priority_id in (?))',
               date, Setting.plugin_redmine_cmi['incidents_tracker'], Setting.plugin_redmine_cmi['priority_low'] ]
      Issue.count :joins => :project, :conditions => cond
    end

    def incident_medium
      cond = [ project.project_condition(Setting.display_subprojects_issues?) <<
               ' AND (start_date <= ?)' <<
               ' AND (tracker_id = ?)' <<
               ' AND (priority_id in (?))',
               date, Setting.plugin_redmine_cmi['incidents_tracker'], Setting.plugin_redmine_cmi['priority_medium'] ]
      Issue.count :joins => :project, :conditions => cond
    end

    def incident_high
      cond = [ project.project_condition(Setting.display_subprojects_issues?) <<
               ' AND (start_date <= ?)' <<
               ' AND (tracker_id = ?)' <<
               ' AND (priority_id in (?))',
               date, Setting.plugin_redmine_cmi['incidents_tracker'], Setting.plugin_redmine_cmi['priority_high'] ]
      Issue.count :joins => :project, :conditions => cond
    end

    def incident_total
      cond = [ project.project_condition(Setting.display_subprojects_issues?) <<
               ' AND (start_date <= ?)' <<
               ' AND (tracker_id = ?)',
               date, Setting.plugin_redmine_cmi['incidents_tracker'] ]
      Issue.count :joins => :project, :conditions => cond
    end

    def changes_accepted
      cond = [ project.project_condition(Setting.display_subprojects_issues?) <<
               ' AND (start_date <= ?)' <<
               ' AND (tracker_id = ?)' <<
               ' AND (status_id in (?))',
               date, Setting.plugin_redmine_cmi['changes_tracker'], Setting.plugin_redmine_cmi['status_accepted'] ]
      Issue.count :joins => :project, :conditions => cond
    end

    def changes_rejected
      cond = [ project.project_condition(Setting.display_subprojects_issues?) <<
               ' AND (start_date <= ?)' <<
               ' AND (tracker_id = ?)' <<
               ' AND (status_id in (?))',
               date, Setting.plugin_redmine_cmi['changes_tracker'], Setting.plugin_redmine_cmi['status_rejected'] ]
      Issue.count :joins => :project, :conditions => cond
    end

    def changes_effort_incurred
      cond = [ project.project_condition(Setting.display_subprojects_issues?) <<
               ' AND (start_date <= ?)' <<
               ' AND (tracker_id = ?)',
               date, Setting.plugin_redmine_cmi['changes_tracker'] ]
      TimeEntry.sum(:hours,
                    :joins => [:project, :issue ],
                    :conditions => cond)
    end

    def changes_effort_percent
      if effort_done.zero?
        0.0
      else
        100.0 * changes_effort_incurred / effort_done
      end
    end

    def held_qa_meetings_percent
      if scheduled_qa_meetings.zero?
        0.0
      else
        100.0 * held_qa_meetings / scheduled_qa_meetings
      end
    end

    def scheduled_qa_meetings
      project.cmi_project_info.scheduled_qa_meetings
    end

    def nc_total
      cond = [ project.project_condition(Setting.display_subprojects_issues?) <<
               ' AND (start_date <= ?)' <<
               ' AND (tracker_id = ?)',
               date, Setting.plugin_redmine_cmi['qa_tracker'] ]
      Issue.count :joins => :project, :conditions => cond
    end

    def nc_pending
      cond = [ project.project_condition(Setting.display_subprojects_issues?) <<
               ' AND (start_date <= ?)' <<
               ' AND (tracker_id = ?)' <<
               ' AND (status_id in (?))',
               date, Setting.plugin_redmine_cmi['qa_tracker'], Setting.plugin_redmine_cmi['status_pending'] ]
      Issue.count :joins => :project, :conditions => cond
    end

    def nc_out_of_date
      cond = [ project.project_condition(Setting.display_subprojects_issues?) <<
               ' AND (start_date <= ?)' <<
               ' AND (tracker_id = ?)' <<
               ' AND (due_date < ?)',
               date, Setting.plugin_redmine_cmi['qa_tracker'], date ]
      Issue.count :joins => :project, :conditions => cond
    end

    def nc_no_date
      cond = [ project.project_condition(Setting.display_subprojects_issues?) <<
               ' AND (start_date <= ?)' <<
               ' AND (tracker_id = ?)' <<
               ' AND (due_date IS NULL)',
               date, Setting.plugin_redmine_cmi['qa_tracker'] ]
      Issue.count :joins => :project, :conditions => cond
    end

    def qa_effort_incurred
      cond = [ project.project_condition(Setting.display_subprojects_issues?) <<
               ' AND (start_date <= ?)' <<
               ' AND (tracker_id = ?)',
               date, Setting.plugin_redmine_cmi['qa_tracker'] ]
      TimeEntry.sum(:hours,
                    :joins => [:project, :issue ],
                    :conditions => cond)
    end

    def qa_effort_percent
      if effort_done.zero?
        0.0
      else
        100.0 * qa_effort_incurred / effort_done
      end
    end
  end
end
