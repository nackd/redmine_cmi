module CMI
  class ReportMetrics
    unloadable

    def initialize(report, current=false)
      @report = report
      @project = report.project
      # TODO get rid of the following ugly hack (and yesterday)
      @date = current ? Date.today : report.start_date.yesterday
    end

    def effort_done_by_role(role)
      @project.effort_done_by_role(role, @date)
    end

    def effort_planned_by_role(role)
      role_current_effort_planned_name = DEFAULT_VALUES['report_role_current_effort_planned_field'].gsub('{{role}}', role)
      role_current_effort_planned = IssueCustomField.find_by_name(role_current_effort_planned_name)
      @report.custom_value_for(role_current_effort_planned).value.to_f rescue 0.0
    end

    def effort_remaining_by_role(role)
      effort_planned_by_role(role) - effort_done_by_role(role)
    end

    def effort_percent_by_role(role)
      effort_done_by_role(role) * 100 / effort_planned_by_role(role)
    end

    private

    def method_missing(method, *args, &block)
      @report.send method, *args, &block
    end
  end
end
