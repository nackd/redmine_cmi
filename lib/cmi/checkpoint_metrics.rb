module CMI
  class CheckpointMetrics < Metrics
    unloadable

    def initialize(checkpoint)
      @checkpoint = checkpoint
      @project = checkpoint.project
      # TODO get rid of the yesterday thing
      @date = checkpoint.checkpoint_date.yesterday
    end

    def effort_done_by_role(role)
      @project.effort_done_by_role(role, @date)
    end

    def effort_scheduled_by_role(role)
      @checkpoint.scheduled_role_effort[role]
    end

    def conf_effort_incurred
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['spent_on <= ?', @date]
      cond << ['issue_categories.name = ?', Setting.plugin_redmine_cmi['conf_category']]
      TimeEntry.sum(:hours,
                    :joins => [:project, {:issue => :category} ],
                    :conditions => cond.conditions)
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

    def risk_low
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['start_date <= ?', @date]
      cond << ['tracker_id = ?', Setting.plugin_redmine_cmi['risks_tracker']]
      cond << ['priority_id in (?)', Setting.plugin_redmine_cmi['risk_low']]
      Issue.count :joins => :project, :conditions => cond.conditions
    end

    def risk_medium
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['start_date <= ?', @date]
      cond << ['tracker_id = ?', Setting.plugin_redmine_cmi['risks_tracker']]
      cond << ['priority_id in (?)', Setting.plugin_redmine_cmi['risk_medium']]
      Issue.count :joins => :project, :conditions => cond.conditions
    end

    def risk_high
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['start_date <= ?', @date]
      cond << ['tracker_id = ?', Setting.plugin_redmine_cmi['risks_tracker']]
      cond << ['priority_id in (?)', Setting.plugin_redmine_cmi['risk_high']]
      Issue.count :joins => :project, :conditions => cond.conditions
    end

    def risk_total
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['start_date <= ?', @date]
      cond << ['tracker_id = ?', Setting.plugin_redmine_cmi['risks_tracker']]
      Issue.count :joins => :project, :conditions => cond.conditions
    end

    def incident_low
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['start_date <= ?', @date]
      cond << ['tracker_id = ?', Setting.plugin_redmine_cmi['incidents_tracker']]
      cond << ['priority_id in (?)', Setting.plugin_redmine_cmi['priority_low']]
      Issue.count :joins => :project, :conditions => cond.conditions
    end

    def incident_medium
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['start_date <= ?', @date]
      cond << ['tracker_id = ?', Setting.plugin_redmine_cmi['incidents_tracker']]
      cond << ['priority_id in (?)', Setting.plugin_redmine_cmi['priority_medium']]
      Issue.count :joins => :project, :conditions => cond.conditions
    end

    def incident_high
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['start_date <= ?', @date]
      cond << ['tracker_id = ?', Setting.plugin_redmine_cmi['incidents_tracker']]
      cond << ['priority_id in (?)', Setting.plugin_redmine_cmi['priority_high']]
      Issue.count :joins => :project, :conditions => cond.conditions
    end

    def incident_total
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['start_date <= ?', @date]
      cond << ['tracker_id = ?', Setting.plugin_redmine_cmi['incidents_tracker']]
      Issue.count :joins => :project, :conditions => cond.conditions
    end

    def changes_accepted
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['start_date <= ?', @date]
      cond << ['tracker_id = ?', Setting.plugin_redmine_cmi['changes_tracker']]
      cond << ['status_id in (?)', Setting.plugin_redmine_cmi['status_accepted']]
      Issue.count :joins => :project, :conditions => cond.conditions
    end

    def changes_rejected
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['start_date <= ?', @date]
      cond << ['tracker_id = ?', Setting.plugin_redmine_cmi['changes_tracker']]
      cond << ['status_id in (?)', Setting.plugin_redmine_cmi['status_rejected']]
      Issue.count :joins => :project, :conditions => cond.conditions
    end

    def changes_effort_incurred
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['start_date <= ?', @date]
      cond << ['tracker_id = ?', Setting.plugin_redmine_cmi['changes_tracker']]
      TimeEntry.sum(:hours,
                    :joins => [:project, :issue ],
                    :conditions => cond.conditions)
    end

    def nc_total
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['start_date <= ?', @date]
      cond << ['tracker_id = ?', Setting.plugin_redmine_cmi['qa_tracker']]
      Issue.count :joins => :project, :conditions => cond.conditions
    end

    def nc_pending
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['start_date <= ?', @date]
      cond << ['tracker_id = ?', Setting.plugin_redmine_cmi['qa_tracker']]
      cond << ['status_id in (?)', Setting.plugin_redmine_cmi['status_pending']]
      Issue.count :joins => :project, :conditions => cond.conditions
    end

    def nc_out_of_date
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['start_date <= ?', @date]
      cond << ['tracker_id = ?', Setting.plugin_redmine_cmi['qa_tracker']]
      cond << ['due_date > ?', Date.today]
      Issue.count :joins => :project, :conditions => cond.conditions
    end

    def nc_no_date
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['start_date <= ?', @date]
      cond << ['tracker_id = ?', Setting.plugin_redmine_cmi['qa_tracker']]
      cond << ['due_date is null']
      Issue.count :joins => :project, :conditions => cond.conditions
    end

    def qa_effort_incurred
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['start_date <= ?', @date]
      cond << ['tracker_id = ?', Setting.plugin_redmine_cmi['qa_tracker']]
      TimeEntry.sum(:hours,
                    :joins => [:project, :issue ],
                    :conditions => cond.conditions)
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
