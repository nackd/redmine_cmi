class MetricsController < ApplicationController
  unloadable
  menu_item :metrics
  before_filter :require_project_jp, :find_project, :obtain_profile_costs
  include CMI::ProjectCalculations

  def show
    begin
      @profile_alert = false
      unless @project.nil?
        tracker_informes = @project.trackers.find_by_name(DEFAULT_VALUES['trackers']['report'])
        @spent_issues_informes = (@project.issues.find(:all,
                                                       :include => [:tracker],
                                                       :conditions => ["tracker_id=?", tracker_informes.id],
                                                       :order => 'start_date DESC'))
        @spent_issues_informes = params[:metrics].nil? ? @spent_issues_informes[0..1] : @spent_issues_informes
        general_data_on_selected_reports
      end
      respond_to do |format|
          format.html { render :template => 'metrics/show', :layout => !request.xhr? }
          format.js { render(:update) {|page| page.replace_html "tab-content-metrics", :partial => 'metrics/show_metrics'} }
      end
    rescue Exception => exc
      ActiveRecord::Base.logger.error("[#{DateTime.now}] Error message: #{exc.message}, #{exc.backtrace}")
      
      if @profile_alert
        flash[:error] = "Hay usuarios (#{@no_profile_users.join(',')}) sin perfil asignado en el proyecto '#{@project}'. Es necesario para poder realizar los cálculos correctamente."
      else
        flash[:error] = "Faltan datos por introducir en el proyecto '#{@project}' para poder realizar los cálculos correctamente. Se ha producido un error en los cálculos."
      end
      redirect_back_or_default('')
    end
  end

  private

  def general_data_on_selected_reports
    @names = []
    @spent_issues_informes.each do |informe|
      if (informe == @spent_issues_informes.first)
        @date = Date.tomorrow
        instance_variable_set("@metrics_actual", calculate_metrics(@project, informe))
        @names << "actual"
      end
      @date = informe.start_date
      instance_variable_set("@metrics_#{informe.id}", calculate_metrics(@project, informe))
      @names << "#{informe.id}"
    end
  end

  def initial_data_on_expense_issues(project, project_metrics)
#     Esto encuentra el listado de tickets de Gastos
    project_metrics["#{DEFAULT_VALUES['budget_spected_rrmm']}"] = 0.0
    project_metrics["#{DEFAULT_VALUES['report_material_current_budget_field']}"] = 0.0
    project_metrics['Gastado'] = 0.0

    tracker_gastos = project.trackers.find_by_name(DEFAULT_VALUES['trackers']['expense'])
    cond = ARCondition.new
    cond << [ 'tracker_id=?', tracker_gastos.id]
    cond << ['created_on BETWEEN ? AND ?', project.created_on, (@date.to_s).to_datetime]
    spent_issues_gastos = (project.issues.find( :all,
                                        :include => [:tracker],
                                        :conditions => cond.conditions))

    spent_issues_gastos.each do |spent_issue_gastos|
      spent_issue_gastos.custom_values.each { |custom_value|
         project_metrics["#{DEFAULT_VALUES['budget_spected_rrmm']}"] += custom_value.value.to_f if custom_value.custom_field.name == "#{DEFAULT_VALUES['report_material_original_budget_field']}"
         project_metrics["#{DEFAULT_VALUES['report_material_current_budget_field']}"] += custom_value.value.to_f if custom_value.custom_field.name == "#{DEFAULT_VALUES['report_material_current_budget_field']}"
         project_metrics['Gastado'] += custom_value.value.to_f if custom_value.custom_field.name == "#{DEFAULT_VALUES['expense_value_field']}"
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
    project_metrics['effort_planned'] = calculate_effort_general(DEFAULT_VALUES['spected'], project_metrics)
    project_metrics['effort_real'] = calculate_effort_general(DEFAULT_VALUES['current'], project_metrics)

    calculate_effort_remaining_general(project_metrics)

    project_metrics['effort_remaining'] = calculate_effort_remaining project_metrics
    project_metrics['budget_planned_rrhh'] = calculate_budget_general_rrhh(DEFAULT_VALUES['spected'], project_metrics)
    project_metrics['budget_planned'] = calculate_budget_planned project_metrics
    project_metrics['budget_real_rrhh'] = calculate_budget_general_rrhh(DEFAULT_VALUES['current'], project_metrics)
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

  def find_project
    @project = Project.find(params[:project_id])
  end

  def obtain_profile_costs
    @hash_cost_actual_year = (HistoryProfilesCost.find :all).group_by(&:year)[Date.today.year].group_by(&:profile)
  end

  def require_project_jp
    return unless require_login
    @project = Project.find(params[:project_id])
    member = @project.members.find_by_user_id(User.current.id)
    if !User.current.admin? and (member.nil? or (!member.nil? and !(member.role_ids).include?(3)))
      render_403
      return false
    end
    true
  end

  def get_project_metrics
    # Para acceder los valor de las diferentes métricas a calcular
    @project_metrics_list = Setting.plugin_redmine_cmiplugin['project_metrics']
  end
end
