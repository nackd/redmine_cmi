class MetricsController < ApplicationController
  unloadable
  menu_item :metrics
  before_filter :find_project_by_project_id, :authorize
  before_filter :obtain_profile_costs, :get_roles
  include CMI::ProjectCalculations

  def show
    begin
      @profile_alert = false
      unless @project.nil?
        tracker_informes = @project.trackers.find_by_name(DEFAULT_VALUES['trackers']['report'])
        raise CMI::Exception, I18n.t(:'cmi.cmi_report_tracker_not_available') if tracker_informes.nil?
        @reports = @project.issues.find(:all,
                                        :include => [:tracker],
                                        :conditions => ["tracker_id=?", tracker_informes.id],
                                        :order => 'start_date DESC')
        @reports = params[:metrics].nil? ? @reports[0..1] : @reports
        raise CMI::Exception, I18n.t(:'cmi.cmi_no_reports_found', :project => @project) if @reports.empty?
        general_data_on_selected_reports
      end
      respond_to do |format|
          format.html { render :template => 'metrics/show', :layout => !request.xhr? }
          format.js { render(:update) {|page| page.replace_html "tab-content-metrics", :partial => 'metrics/show_metrics'} }
      end
    rescue CMI::Exception => e
      flash[:error] = e.message
    rescue Exception => exc
      clean_exception = defined?(Rails) && Rails.respond_to?(:backtrace_cleaner) ?
        Rails.backtrace_cleaner.clean(exc.backtrace) :
        exc.backtrace
      logger.error(
        "\n#{exc.class} (#{exc.message}):\n  " +
        clean_exception.join("\n  ") + "\n\n"
      )
      flash[:error] = I18n.t :'cmi.error_other', :project => @project, :message => exc.message
    end
  end

  private

  def general_data_on_selected_reports
    @names = []
    @reports.each do |report|
      if (report == @reports.first)
        @date = Date.tomorrow
        instance_variable_set("@metrics_actual", calculate_metrics(@project, report))
        @names << "actual"
      end
      @date = report.start_date
      instance_variable_set("@metrics_#{report[:id]}", calculate_metrics(@project, report))
      @names << "#{report[:id]}"
    end
    @reports = [CMI::ReportMetrics.new(@reports.first, true)] + @reports.collect { |report| CMI::ReportMetrics.new report }
  end

  def initial_data_on_expense_issues(project, project_metrics)
#     Esto encuentra el listado de tickets de Gastos
    project_metrics[Setting.plugin_redmine_cmi["field_project_scheduled_material_budget"]] = 0.0
    project_metrics[Setting.plugin_redmine_cmi["field_report_current_material_budget"]] = 0.0
    project_metrics['Gastado'] = 0.0

    tracker_gastos = project.trackers.find_by_name(DEFAULT_VALUES['trackers']['expense'])
    raise CMI::Exception, l(:'cmi.cmi_expense_tracker_not_available') if tracker_gastos.nil?
    cond = ARCondition.new
    cond << [ 'tracker_id=?', tracker_gastos.id]
    cond << ['created_on BETWEEN ? AND ?', project.created_on, (@date.to_s).to_datetime]
    spent_issues_gastos = (project.issues.find( :all,
                                        :include => [:tracker],
                                        :conditions => cond.conditions))

    spent_issues_gastos.each do |spent_issue_gastos|
      spent_issue_gastos.custom_values.each { |custom_value|
         project_metrics[Setting.plugin_redmine_cmi["field_project_scheduled_material_budget"]] += custom_value.value.to_f if custom_value.custom_field.name == Setting.plugin_redmine_cmi['field_report_original_material_budget']
         project_metrics[Setting.plugin_redmine_cmi["field_report_current_material_budget"]] += custom_value.value.to_f if custom_value.custom_field.name == Setting.plugin_redmine_cmi["field_report_current_material_budget"]
         project_metrics['Gastado'] += custom_value.value.to_f if custom_value.custom_field.name == Setting.plugin_redmine_cmi["field_report_expense_cost"]
      }
    end
    return project_metrics
  end

  def calculate_metrics(project, informe)
    project_metrics={}
    CMI::Common.get_customs(project, project_metrics)
    @informe = CMI::Common.get_informe(informe, project_metrics)[1]
    initial_data_on_expense_issues(project, project_metrics)

    #   Esfuerzo realizado (número de horas cargadas al proyecto)
    calculate_effort_done_general(@date, project, project_metrics)
    check_effort_done project, project_metrics

    #   Suma de "no conformidades" en estado "Nueva" o "Validada"
    project_metrics['no_approval_open'] = calculate_no_approval_open project

    #   % de errores vs tareas totales del proyecto (en todos los estados)
    project_metrics['percentaje_errors'] = calculate_percentaje_errors project

    #   Esfuerzo en nuevos requisitos CMMI_Solicitudes de cambio Aceptada, Resuelta o Cerrada
    project_metrics['request_change'] = calculate_request_change project, project_metrics
    project_metrics['time_total_planned'] = calculate_time_total_planned project_metrics
    project_metrics['time_total_real'] = calculate_time_total_real project_metrics
    project_metrics['time_done'] = calculate_time_done project, project_metrics
    project_metrics['time_remaining'] = calculate_time_remaining project, project_metrics
    project_metrics['effort_planned'] = calculate_effort_general(
      Setting.plugin_redmine_cmi["field_project_scheduled_role_effort"], project_metrics)
    project_metrics['effort_real'] = calculate_effort_general(
      Setting.plugin_redmine_cmi["field_report_scheduled_role_effort"], project_metrics)

    calculate_effort_remaining_general(project_metrics)

    project_metrics['effort_remaining'] = calculate_effort_remaining project_metrics
    project_metrics['budget_planned_rrhh'] = calculate_budget_general_rrhh(
      Setting.plugin_redmine_cmi["field_project_scheduled_role_effort"], project_metrics)
    project_metrics['budget_planned'] = calculate_budget_planned project_metrics
    project_metrics['budget_real_rrhh'] = calculate_budget_general_rrhh(
      Setting.plugin_redmine_cmi["field_report_scheduled_role_effort"], project_metrics)
    project_metrics['budget_real'] = calculate_budget_real project_metrics
    project_metrics['budget_spent_rrhh'] = calculate_budget_spent_rrhh project
    project_metrics['budget_spent'] = calculate_budget_spent project_metrics
    project_metrics['budget_remaining_rrhh'] = calculate_budget_remaining_rrhh project_metrics
    project_metrics['budget_remaining_rrmm_and_others'] = calculate_budget_remaining_rrhh_and_others project_metrics
    project_metrics['budget_remaining'] = calculate_budget_remaining project_metrics

    project_metrics['profitability_planned'] = calculate_profitability_general('budget_planned', project_metrics)
    project_metrics['profitability_current'] = calculate_profitability_general('budget_real', project_metrics)
    project_metrics['profitability'] = calculate_profitability_general('budget_spent', project_metrics)
    project_metrics['profitability_percent_planned'] = calculate_profitability_percent_general('budget_planned', project_metrics)
    project_metrics['profitability_percent_current'] = calculate_profitability_percent_general('budget_real', project_metrics)
    project_metrics['profitability_percent'] = calculate_profitability_percent_general('budget_spent', project_metrics)

    project_metrics['risk_low'] = calculate_risk('Bajo', @date, project)
    project_metrics['risk_medium'] = calculate_risk('Medio', @date, project)
    project_metrics['risk_high'] = calculate_risk('Alto', @date, project)
    project_metrics['issues_low'] = calculate_incidence('Bajo', @date, project)
    project_metrics['issues_medium'] = calculate_incidence('Medio', @date, project)
    project_metrics['issues_high'] = calculate_incidence('Alto', @date, project)
    project_metrics['changes_accepted'] = change_request_count(DEFAULT_VALUES['issue_status']['accepted'], @date, project)
    project_metrics['changes_declined'] = change_request_count(DEFAULT_VALUES['issue_status']['rejected'], @date, project)
    project_metrics['changes_effort'] = calculate_request_change project, project_metrics

    project_metrics['conf_effort'] = calculate_conf_effort project

    project_metrics['nc_open'] = calculate_no_approval_open project
    project_metrics['nc_total'] = calculate_no_approval_total project
    project_metrics['ac_effort'] = calculate_ac_effort project
    project_metrics['no_approval_open_out_of_date'] = calculate_no_approval_open_out_of_date project
    project_metrics['no_approval_open_without_date'] = calculate_no_approval_open_without_date project

    return project_metrics
  end

  def obtain_profile_costs
    current_year_costs = (HistoryProfilesCost.find :all).group_by(&:year)[Date.today.year]
    @hash_cost_actual_year = current_year_costs && current_year_costs.group_by(&:profile)
  end

  def get_project_metrics
    # Para acceder los valor de las diferentes métricas a calcular
    @project_metrics_list = Setting.plugin_redmine_cmiplugin['project_metrics']
  end

  def get_roles
    @roles = User.roles
  end
end
