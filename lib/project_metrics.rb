class ProjectMetrics
  unloadable

  attr_reader :project

  def initialize(project)
    @project = project.is_a?(Project) ? project : Project.find(project)
    calculate
  end

  [:accepted, :planned_profit, :done, :deviation, :hr_current_effort_remaining].each do |method|
    define_method method do
      instance_variable_get "@#{method}"
    end
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
