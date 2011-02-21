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

    private

    def method_missing(method, *args, &block)
      @report.send method, *args, &block
    end
  end
end
