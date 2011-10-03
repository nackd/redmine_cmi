module MetricsHelper
  def set_value(profile, report, denominator, numerator)
    instance_variable_set("@value_#{profile.underscore}_#{report}", instance_variable_get("@metrics_#{report}")["#{denominator}"].to_f > 0.0? (instance_variable_get("@metrics_#{report}")["#{numerator}"].to_f * 100 /instance_variable_get("@metrics_#{report}")["#{denominator}"].to_f).round(2) : "0.0")
  end

  def set_cost_value(profile, report, denominator, numerator)
    instance_variable_set("@cost_#{profile.underscore}_#{report}", instance_variable_get("@metrics_#{report}")["#{denominator}"].to_f > 0.0? (instance_variable_get("@metrics_#{report}")["#{numerator}"].to_f * 100 /instance_variable_get("@metrics_#{report}")["#{denominator}"].to_f).round(2) : "0.0")
  end

  def get_report_value(report, denominator, numerator=nil)
    unless numerator.nil?
      instance_variable_get("@metrics_#{report}")["#{denominator}"].to_f > 0.0? (instance_variable_get("@metrics_#{report}")["#{numerator}"].to_f * 100 /instance_variable_get("@metrics_#{report}")["#{denominator}"].to_f).round(2) : 0.0
    else
      instance_variable_get("@metrics_#{report}")["#{denominator}"]
    end
  end

  def effort_done_graph(report, roles)
    total = report.effort_done
    percent = roles.collect { |role| total.zero? ? 0.0 : (report.effort_done_by_role(role) * 100 / total).round(2) }
    labels = roles.enum_for(:each_with_index).collect{ |role, index| "#{role}: #{percent[index]}%" }
    pie_graph(percent, labels)
  end

  def effort_scheduled_graph(report, roles)
    total = report.effort_scheduled
    percent = roles.collect { |role| total.zero? ? 0.0 : (report.effort_scheduled_by_role(role) * 100.0 / total).round(2) }
    labels = roles.enum_for(:each_with_index).collect{ |role, index| "#{role}: #{percent[index]}%" }
    pie_graph(percent, labels)
  end

  def effort_remaining_graph(report, roles)
    total = report.effort_remaining
    percent = roles.collect { |role| total.zero? ? 0.0 : (report.effort_remaining_by_role(role) * 100 / total).round(2) }
    labels = roles.enum_for(:each_with_index).collect{ |role, index| "#{role}: #{percent[index]}%" }
    pie_graph(percent, labels)
  end

  private

  def pie_graph(data, labels, opts = {})
    t = data.join(',')
    l = labels.join('|')
    "<img src=\"http://chart.apis.google.com/chart?cht=p3&chs=220x50&chd=t:#{t}&chl=#{l}\" />"
  end
end
