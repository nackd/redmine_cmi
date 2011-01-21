module ManagementHelper
  def link_to_metrics(project)
    if project.last_report.present?
      link_to "#{DEFAULT_VALUES['trackers']['report']} ##{project.last_report.id} #{project.last_report.start_date}", metrics_path(project.last_report.project.identifier)
    elsif !project.module_enabled?(:cmiplugin)
      l('cmi.cmi_module_not_enabled')
    elsif !project.report_tracker?
      l('cmi.cmi_report_tracker_not_available')
    else
      l('cmi.cmi_no_reports')
    end
  end

  def accepted_graph(metrics)
    groups = metrics.keys.sort
    total = groups.sum{ |group| metrics[group][:accepted]}
    percent = groups.collect{ |group| total.zero? ? 0.0 : (metrics[group][:accepted] * 100 / total).round(2) }

    t = percent.join(',')
    labels = groups.enum_for(:each_with_index).collect{ |group, index| "#{group}: #{percent[index]}%" }.join('|')
    "<img src=\"http://chart.apis.google.com/chart?cht=p3&chd=t:#{t}&chs=320x50&chl=#{labels}&chf=bg,s,65432100\" />"
  end

  def profit_graph(metrics)
    groups = metrics.keys.sort
    profit = groups.collect{ |group| metrics[group][:planned_profit].round(2) }
    labels = groups.enum_for(:each_with_index).collect{ |group, index| "#{group}: #{profit[index]}" }

    bar_graph(profit, labels)
  end

  def deviation_graph(metrics)
    groups = metrics.keys.sort
    deviation = groups.collect{ |group| metrics[group][:deviation].round(2) }
    labels = groups.enum_for(:each_with_index).collect{ |group, index| "#{group}: #{deviation[index]}" }

    bar_graph(deviation, labels)
  end

  def cm_graph(metrics)
    groups = metrics.keys.sort
    cm = groups.collect{ |group| (metrics[group][:cm] * 100).round(2) }
    labels = groups.enum_for(:each_with_index).collect{ |group, index| "#{group}: #{cm[index]}%" }

    bar_graph(cm, labels, :max => 100)
  end

  # TODO: This is a temporary redefinition for compatibility with Redmine 1.0.0
  if not ApplicationHelper.instance_methods.include?(:link_to_project)
    # Generates a link to a project if active
    # Examples:
    #
    #   link_to_project(project)                          # => link to the specified project overview
    #   link_to_project(project, :action=>'settings')     # => link to project settings
    #   link_to_project(project, {:only_path => false}, :class => "project") # => 3rd arg adds html options
    #   link_to_project(project, {}, :class => "project") # => html options with default url (project overview)
    #
    def link_to_project(project, options={}, html_options = nil)
      if project.active?
        url = {:controller => 'projects', :action => 'show', :id => project}.merge(options)
        link_to(h(project), url, html_options)
      else
        h(project)
      end
    end
  end

  private

  def bar_graph(data, labels, opts = {})
    min = data.min
    max = opts[:max] || data.max
    t = "#{data.join(',')}|#{([max.to_s] * data.length).join(',')}"
    l = labels.reverse.join('|')
    "<img src=\"http://chart.apis.google.com/chart?cht=bhs&chco=4D89F9,C6D9FD&chbh=10,5,10&chs=290x170&chxt=x,y&chxr=0,#{min},#{max}&chds=#{min},#{max}&chd=t:#{t}&chxl=1:|#{l}&chf=bg,s,65432100\" />"
  end
end
