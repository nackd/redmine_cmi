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
end
