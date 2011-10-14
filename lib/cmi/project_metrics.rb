module CMI
  class ProjectMetrics
    unloadable

    attr_reader :project

    def initialize(project)
      @project = project.is_a?(Project) ? project : Project.find(project)
      @last_checkpoint = project.cmi_checkpoints.find(:first,
                                                      :order => 'checkpoint_date DESC')
      calculate
    end

    [:accepted, :planned_profit, :done, :deviation, :hr_current_effort_remaining].each do |method|
      define_method method do
        instance_variable_get "@#{method}"
      end
    end

    def effort_done
      User.roles.inject(0.0) { |sum, role| sum + effort_done_by_role(role) }
    end

    def effort_done_by_role(role)
      @project.effort_done_by_role(role, Date.today)
    end

    def effort_scheduled
      User.roles.inject(0) { |sum, role| sum + effort_scheduled_by_role(role) }
    end

    def effort_scheduled_by_role(role)
      @last_checkpoint.scheduled_role_effort[role]
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
      if effort_scheduled.zero?
        0.0
      else
        100.0 * effort_done / effort_scheduled
      end
    end

    def effort_original_by_role(role)
      @project.cmi_project_info.scheduled_role_effort[role]
    end

    def effort_original
      User.roles.inject(0) { |sum, role| sum + effort_original_by_role(role) }
    end

    def effort_deviation
      if effort_original.zero?
        0.0
      else
        100.0 * (effort_scheduled - effort_original) / effort_original
      end
    end

    def conf_effort_incurred
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['spent_on <= ?', Date.today]
      cond << ['issue_categories.name = ?', Setting.plugin_redmine_cmi['conf_category']]
      TimeEntry.sum(:hours,
                    :joins => [:project, {:issue => :category} ],
                    :conditions => cond.conditions)
    end

    def conf_effort_percent
      if effort_done.zero?
        0.0
      else
        100.0 * conf_effort_incurred / effort_done
      end
    end

    def time_done
      if !@project.cmi_project_info.actual_start_date.nil?
          (Date.today - @project.cmi_project_info.actual_start_date + 1).to_i
      else
          "--"
      end
    end

    def time_scheduled
      (@last_checkpoint.scheduled_finish_date - @project.cmi_project_info.actual_start_date).to_i
    end

    def time_remaining
      if !@project.cmi_project_info.actual_start_date.nil?
        (@last_checkpoint.scheduled_finish_date - Date.today - 1).to_i
      else
        "--"
      end
    end

    def time_percent_done
      if time_scheduled.zero?
        0.0
      else
        100.0 * time_done / time_scheduled
      end
    end

    def time_original
      @project.cmi_project_info.scheduled_finish_date - @project.cmi_project_info.scheduled_start_date
    end

    def time_deviation
      100.0 * (time_scheduled - time_original) / time_original
    end

    def hhrr_cost_incurred
      cond = ARCondition.new << @project.project_condition(Setting.display_subprojects_issues?)
      cond << ['spent_on <= ?', Date.today]
      TimeEntry.sum(:cost,
                    :joins => :project,
                    :conditions => cond.conditions)
    end

    def hhrr_cost_scheduled
      User.roles.inject(0) { |sum, role|
        sum += (@last_checkpoint.scheduled_role_effort[role] *
                HistoryProfilesCost.find(:first, :conditions => ['profile = ? AND year = ?', role, Date.today.year]).value)
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

    def total_cost_deviation
      100.0 * (total_cost_scheduled - total_cost_original) / total_cost_original
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
      # TODO translate this
      "Valor actual - #{Date.today}"
    end

    private

    def calculate
      project_accepted_field = ProjectCustomField.find_by_name(DEFAULT_VALUES['project_accepted_field'])
      report_material_current_budget_field = IssueCustomField.find_by_name(DEFAULT_VALUES['report_material_current_budget_field'])
      report_material_original_budget_field = IssueCustomField.find_by_name(DEFAULT_VALUES['report_material_original_budget_field'])

      @accepted = @project.custom_value_for(project_accepted_field).value.to_f rescue 0.0
      @material_current_budget = @project.last_report.custom_value_for(report_material_current_budget_field).value.to_f rescue 0.0
      @material_original_budget = @project.last_report.custom_value_for(report_material_original_budget_field).value.to_f rescue 0.0

      @hr_effort_done = {}
      @hr_current_effort_planned = {}
      @hr_original_effort_planned = {}
      @hr_current_effort_remaining = {}
      User.roles.each do |role|
        @hr_effort_done[role] = @project.effort_done_by_role(role, @project.last_report.start_date) rescue 0.0

        role_current_effort_planned_name = DEFAULT_VALUES['report_role_current_effort_planned_field'].gsub('{{role}}', role)
        role_current_effort_planned = IssueCustomField.find_by_name(role_current_effort_planned_name)
        @hr_current_effort_planned[role] = @project.last_report.custom_value_for(role_current_effort_planned).value.to_f rescue 0.0

        if role == 'JP' # TODO Fix this shit
          role_original_effort_planned_name = DEFAULT_VALUES['project_role_original_effort_planned_field'].gsub('{{role}}', "el JP")
        else
          role_original_effort_planned_name = DEFAULT_VALUES['project_role_original_effort_planned_field'].gsub('{{role}}', role)
        end
        role_original_effort_planned = ProjectCustomField.find_by_name(role_original_effort_planned_name)
        @hr_original_effort_planned[role] = @project.custom_value_for(role_original_effort_planned).value.to_f rescue 0.0

        @hr_current_effort_remaining[role] = @hr_current_effort_planned[role] - @hr_effort_done[role]
      end

      # TODO use report year instead of current
      costs = HistoryProfilesCost.all.group_by(&:year)[Date.today.year].group_by(&:profile)
      @hr_current_spent_budget = 0.0
      @hr_current_effort_planned.each { |role, effort| @hr_current_spent_budget += effort * costs[role].first.value }

      # TODO use report year instead of current
      @hr_original_budget = 0.0
      @hr_original_effort_planned.each { |role, effort| @hr_original_budget += effort * costs[role].first.value }

      # TODO Date.tomorrow? why not @project.last_report.start_date?
      @hr_spent = @project.hr_spent(Date.tomorrow)

      expense_value_field = IssueCustomField.find_by_name(DEFAULT_VALUES['expense_value_field'])
      @material_spent = @project.expenses.sum{ |e| e.custom_value_for(expense_value_field).value.to_f rescue 0.0 }

      # TODO @hr_current_spent_budget vs. @hr_spent
      @current_budget = @hr_current_spent_budget + @material_current_budget

      @original_budget = @hr_original_budget + @material_original_budget

      @planned_profit = @accepted - @current_budget

      @deviation_percent = @original_budget.zero? ? 0.0 : (@original_budget - @current_budget) / @original_budget

      @deviation = - @deviation_percent * @accepted

      @done = @current_budget.zero? ? 0.0 : (@hr_spent + @material_current_budget) / @current_budget

      @cm = @accepted.zero? ? 0.0 : @planned_profit / @accepted
    end
  end
end
