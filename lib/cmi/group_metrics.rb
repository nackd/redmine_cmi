module CMI
  class GroupMetrics
    unloadable

    def projects
      return @projects if @projects
      group_field = ProjectCustomField.find_by_name(DEFAULT_VALUES['project_group_field'])
      @projects = Project.all(:select => 'projects.*',
                              :joins => :enabled_modules,
                              :conditions => ['enabled_modules.name = ?', 'cmiplugin']).group_by do |p|
        p.custom_value_for(group_field).value if p.custom_value_for(group_field)
      end
    end

    def metrics
      return @metrics if @metrics

      @metrics = {}
      Project.groups.each do |group|
        @metrics[group] = {
          :accepted => 0.0,
          :planned_profit => 0.0,
          :done => 0.0,
          :deviation => 0.0,
          :hr_current_effort_remaining => {}}
        User.roles.each do |role|
          @metrics[group][:hr_current_effort_remaining][role] = 0.0
        end

        (projects[group] || []).each do |project|
          metrics = CMI::ProjectMetrics.new project
          @metrics[group][:accepted] += metrics.total_income
          @metrics[group][:planned_profit] += metrics.scheduled_margin
          @metrics[group][:done] += metrics.done
          @metrics[group][:deviation] += metrics.deviation

          User.roles.each do |role|
            @metrics[group][:hr_current_effort_remaining][role] += metrics.hr_current_effort_remaining[role]
          end
        end

        @metrics[group][:cm] = @metrics[group][:accepted].zero? ? 0.0 : @metrics[group][:planned_profit] / @metrics[group][:accepted]
        @metrics[group][:deviation_percent] = @metrics[group][:accepted].zero? ? 0.0 : @metrics[group][:deviation] / @metrics[group][:accepted]
      end
      @metrics
    end

    def total_accepted
      return @total_accepted if @total_accepted

      @total_accepted = 0.0
      metrics.each do |group, group_metrics|
        @total_accepted += group_metrics[:accepted]
      end
      @total_accepted
    end

    def total_deviation
      return @total_deviation if @total_deviation

      @total_deviation = 0.0
      metrics.each do |group, group_metrics|
        @total_deviation += group_metrics[:deviation]
      end
      @total_deviation
    end

    def total_planned_profit
      return @total_planned_profit if @total_planned_profit

      @total_planned_profit = 0.0
      metrics.each do |group, group_metrics|
        @total_planned_profit += group_metrics[:planned_profit]
      end
      @total_planned_profit
    end

    def total_cm
      total_accepted.zero? ? 0.0 : total_planned_profit / total_accepted
    end

    def total_deviation_percent
      total_accepted.zero? ? 0.0 : total_deviation / total_accepted
    end
  end
end
