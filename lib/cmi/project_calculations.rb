module CMI
  module ProjectCalculations
    unloadable

    def check_effort_done project, project_metrics
      effort_done = 0.0
      effort_done_total = 0.0
      cond = ARCondition.new
      cond << project.project_condition(Setting.display_subprojects_issues?)
      cond << ['spent_on BETWEEN ? AND ?', 0, @date]

      effort_done_total = TimeEntry.sum(:hours,
                                     :include => :project,
                                     :conditions => cond.conditions).round(2)

      effort_done = (project_metrics['effort_done_ap'].to_f + project_metrics['effort_done_af'].to_f + project_metrics['effort_done_jp'].to_f + project_metrics['effort_done_ps'].to_f + project_metrics['effort_done_pj'].to_f + project_metrics['effort_done_b'].to_f).round(2)
      if effort_done_total != effort_done
        @no_profile_users = []
        project.users.each do |user|
          if user.role.nil?
            @no_profile_users << user
          end
        end
        effort_done = effort_done_total
        if @no_profile_users.length > 0
          @profile_alert = true
          raise
        end
      end
      return effort_done.to_s
    end

    def calculate_profitability_general budget_type, project_metrics
      profitability_planned = 0.0
      profitability_planned = project_metrics['Cantidad aceptada'].to_f  - project_metrics[budget_type].to_f
      return profitability_planned.round(2).to_s
    end

    def calculate_profitability_percent_general budget_type, project_metrics
      profitability_percent_planned = 0.0
      profitability_percent_planned = project_metrics['Cantidad aceptada'].to_f != 0.0 ? ((project_metrics['Cantidad aceptada'].to_f  - project_metrics[budget_type].to_f)/project_metrics['Cantidad aceptada'].to_f) : 0.0
      return profitability_percent_planned.round(2).to_s
    end
    
    def calculate_conf_effort project
      return 0.0
      conf_effort = 0.0
        issue_categorys = IssueCategory.find :all, :conditions => ["name = ?", "Configuración"]
        issue_cat_id = []
        issue_categorys.each do |i_cat|
          issue_cat_id << i_cat.id
        end
        tracker_tareas = project.trackers.find_by_name(DEFAULT_VALUES['trackers']['feature'])
        cond = ARCondition.new
        cond << ['created_on BETWEEN ? AND ?', 0, @date]
        cond << ["tracker_id = ? and category_id IN (#{issue_cat_id.join(',')})",tracker_tareas.id]

        conf_effort_list = (project.issues.find(:all,
                                            :include => [:tracker],
                                            :conditions => cond.conditions))

        conf_effort_list.each do |issue|
              conf_effort += issue.time_entries.sum(:hours,
                                     :include =>  :project).to_f
        end
      return conf_effort.to_s
    end

    def calculate_risk(level, to_date, project)
      risk_tracker = project.trackers.find_by_name(DEFAULT_VALUES['trackers']['risk'])
      raise CMI::Exception, l(:'cmi.cmi_risk_tracker_not_available') if risk_tracker.nil?
      cond = ARCondition.new
      cond << ['created_on < ?', to_date]
      cond << ['tracker_id = ?', risk_tracker.id]
      cond << ["#{Enumeration.table_name}.name IN (?)", DEFAULT_VALUES['risk_levels'][level]]
      project.issues.calculate(:count,
                               :all,
                               :include => [:priority, :tracker],
                               :conditions => cond.conditions).to_s
    end

    def calculate_incidence(level, to_date, project)
      incidence_tracker = project.trackers.find_by_name(DEFAULT_VALUES['trackers']['incidence'])
      raise CMI::Exception, l(:'cmi.cmi_incidence_tracker_not_available') if incidence_tracker.nil?
      cond = ARCondition.new
      cond << ['created_on < ?', to_date]
      cond << ['tracker_id = ?', incidence_tracker.id]
      cond << ["#{Enumeration.table_name}.name IN (?)", DEFAULT_VALUES['incidence_levels'][level]]
      project.issues.calculate(:count,
                               :all,
                               :include => [:priority, :tracker],
                               :conditions => cond.conditions).to_s
    end

    def change_request_count(statuses, to_date, project)
      change_request_tracker = project.trackers.find_by_name(DEFAULT_VALUES['trackers']['change'])
      cond = ARCondition.new
      cond << ['created_on < ?', to_date]
      cond << ['tracker_id = ?', change_request_tracker.id]
      cond << ["#{IssueStatus.table_name}.name IN (?)", statuses]
      project.issues.count(:conditions => cond.conditions)
    end

    def calculate_effort_done_general(to_date, project, project_metrics)
      project_metrics['effort_done'] = 0.0
      [l('cmi.label_JP'), l('cmi.label_AF'), l('cmi.label_AP'), l('cmi.label_PS'), l('cmi.label_PJ'), l('cmi.label_B')].each do |role|
        cond = ARCondition.new
        cond << project.project_condition(Setting.display_subprojects_issues?)
        cond << ['role = ?', role]
        cond << ['spent_on < ?', to_date]
        project_metrics["effort_done_#{role.underscore}"] = TimeEntry.sum(:hours,
                                                                          :include => [:project],
                                                                          :conditions => cond.conditions)

        project_metrics['effort_done'] += project_metrics["effort_done_#{role.underscore}"]
      end
      return project_metrics
    end

    def calculate_effort_general budget_type, project_metrics
      effort = 0.0
      [l('cmi.label_JP'), l('cmi.label_AF'), l('cmi.label_AP'), l('cmi.label_PS'), l('cmi.label_PJ'), l('cmi.label_B')].each do |profile|
        effort += project_metrics["#{DEFAULT_VALUES['effort'].gsub('{{type}}', budget_type).gsub('{{profile}}', profile)}"].to_f
      end
      return effort.round(2).to_s + " #{l('cmi.label_hours')}"
    end

    def calculate_effort_remaining_general project_metrics
      [l('cmi.label_JP'), l('cmi.label_AF'), l('cmi.label_AP'), l('cmi.label_PS'), l('cmi.label_PJ'), l('cmi.label_B')].each do |role|
        project_metrics["effort_remaining_#{role.underscore}"] = project_metrics["Esfuerzo actual #{l('cmi.label_' + role)}"].nil? ? "-- #{l('cmi.label_hours')}" :
                                                    (project_metrics["Esfuerzo actual #{l('cmi.label_' + role)}"].to_f -
                                                    project_metrics['effort_done_' + role.underscore].to_f).round(2).to_s + " #{l('cmi.label_hours')}"
      end
      return project_metrics
    end

    def calculate_effort_remaining project_metrics
      effort_remaining = 0.0
      effort_remaining = project_metrics['effort_real'].to_f  - project_metrics['effort_done'].to_f
      return effort_remaining.round(2).to_s + " #{l('cmi.label_hours')}"
    end

    def calculate_budget_general_rrhh budget_type, project_metrics
      budget_general_rrhh = 0.0
      [l('cmi.label_JP'), l('cmi.label_AF'), l('cmi.label_AP'), l('cmi.label_PS'), l('cmi.label_PJ'), l('cmi.label_B')].each do |profile|
        budget_general_rrhh += project_metrics["#{DEFAULT_VALUES['effort'].gsub('{{type}}', "#{budget_type}").gsub('{{profile}}', profile)}"].to_f * @hash_cost_actual_year[profile].first.value
      end
      return budget_general_rrhh.round(2)
    end

    def calculate_budget_planned project_metrics
      budget_planned_rrhh = 0.0
      budget_planned_rrhh = project_metrics['budget_planned_rrhh'].to_f +
                                project_metrics["#{DEFAULT_VALUES['budget_spected_rrmm']}"].to_f
      return budget_planned_rrhh.round(2).to_s
    end

    def calculate_budget_real project_metrics
      budget_real = 0.0
      budget_real = project_metrics['budget_real_rrhh'].to_f +
                                project_metrics["#{DEFAULT_VALUES['report_material_current_budget_field']}"].to_f
      return budget_real.round(2).to_s
    end

    def calculate_budget_spent_rrhh project
      budget_spent_rrhh = 0.0
      cond = ARCondition.new
      cond << project.project_condition(Setting.display_subprojects_issues?)
      cond << ['spent_on BETWEEN ? AND ?', 0, @date]
      budget_spent_rrhh = TimeEntry.sum(:cost,
                                     :include => [:project],
                                     :conditions => cond.conditions)
      return budget_spent_rrhh.round(2).to_s
    end

    def calculate_budget_spent project_metrics
      budget_spent = 0.0
      budget_spent = project_metrics['budget_spent_rrhh'].to_f + project_metrics['Gastado'].to_f
      return budget_spent.round(2).to_s
    end

    def calculate_budget_remaining_rrhh project_metrics
      budget_remaining_rrhh = 0.0
      budget_remaining_rrhh = project_metrics['budget_real_rrhh'].to_f -
                                project_metrics['budget_spent_rrhh'].to_f
      return budget_remaining_rrhh.round(2).to_s
    end

    def calculate_budget_remaining_rrhh_and_others project_metrics
      budget_remaining_rrhh = 0.0
      budget_remaining_rrhh = project_metrics["#{DEFAULT_VALUES['report_material_current_budget_field']}"].to_f -
                                project_metrics['Gastado'].to_f
      return budget_remaining_rrhh.round(2).to_s
    end

    def calculate_budget_remaining project_metrics
      budget_remaining_rrhh = 0.0
      budget_remaining_rrhh = project_metrics['budget_real'].to_f -
                                project_metrics['budget_spent'].to_f
      return budget_remaining_rrhh.round(2).to_s
    end

    # Tiempo del proyecto en marcha. Unidad: días naturales.
    def calculate_time_done project, project_metrics
      time_done = 0.0
      if !project_metrics["#{DEFAULT_VALUES['date_start_real']}"].nil?
          time_done = (@date - (Date.parse(project_metrics["#{DEFAULT_VALUES['date_start_real']}"]))).to_s
      else
          time_done = "--"
      end
      return time_done + ' días'
    end

    #  Tiempo para terminar el proyecto. Unidad:días naturales.
    def calculate_time_remaining project, project_metrics
      time_remaining = 0.0
      if !project_metrics["#{DEFAULT_VALUES['spected_date_end']}"].nil?
          time_remaining = ((Date.parse(project_metrics["#{DEFAULT_VALUES['spected_date_end']}"])) - @date).to_s
      else
          time_remaining = "--"
      end
      return time_remaining + ' días'
    end

    #  Dureción del proyecto planificada
    def calculate_time_total_planned project_metrics
      time_total_planned = 0.0
      time_total_planned = ((Date.parse(project_metrics["#{DEFAULT_VALUES['date_end_planned']}"])) - (Date.parse(project_metrics['Fecha de comienzo planificada']))).to_s + ' días'
      return time_total_planned
    end

    #  Duración del proyecto
    def calculate_time_total_real project_metrics
      time_total_real = 0.0
      if !project_metrics["#{DEFAULT_VALUES['spected_date_end']}"].nil? and !project_metrics["#{DEFAULT_VALUES['date_start_real']}"].nil?
          time_total_real = ((Date.parse(project_metrics["#{DEFAULT_VALUES['spected_date_end']}"]) || 0.0) - (Date.parse(project_metrics["#{DEFAULT_VALUES['date_start_real']}"]))).to_s
      else
          time_total_real = "--"
      end
      return time_total_real + ' días'
    end

    def calculate_no_approval_open project
      ### Suma de "no conformidades" en estado "Nueva" o "Validada"
        #debugger(1)
        risks=project.trackers.find_by_name(DEFAULT_VALUES['trackers']['qa'])
        raise CMI::Exception, l(:'cmi.cmi_qa_tracker_not_available') if risks.nil?
        cond = ARCondition.new
        if @informe
          cond << ['created_on BETWEEN ? AND ?', 0, @date]
        end
        cond << ["(#{IssueStatus.table_name}.name=? or #{IssueStatus.table_name}.name=?)
                                                      and tracker_id=?" ,DEFAULT_VALUES['issue_status']['new'],DEFAULT_VALUES['issue_status']['approval'],risks.id]

        # añadir tipo_registro = no conformidad
        project.issues.calculate(:count,:all,
                                 :include => [:tracker, :status] ,
                                 :conditions => cond.conditions)
    end

    def calculate_no_approval_total project
      ### Suma de "no conformidades"
        #debugger(1)
        error_calidad="No existe el tracker #{DEFAULT_VALUES['trackers']['qa']}"
        risks=project.trackers.find_by_name(DEFAULT_VALUES['trackers']['qa'])
        cond = ARCondition.new
        cond << ['created_on BETWEEN ? AND ?', 0, @date]
        cond << [" tracker_id=?" ,risks.id]
        # añadir tipo_registro = no conformidad
        if !risks.nil?
          no_approval_total=project.issues.calculate(:count,:all,
                                   :include => [:tracker] ,
                                   :conditions => cond.conditions)
        else
          no_approval_total = error_calidad
        end
        return no_approval_total
    end

    def calculate_no_approval_open_out_of_date project

        error_calidad="No existe el tracker #{DEFAULT_VALUES['trackers']['qa']}"
        risks=project.trackers.find_by_name(DEFAULT_VALUES['trackers']['qa'])
        cond = ARCondition.new
        cond << ['created_on BETWEEN ? AND ?', 0, @date]
        cond << [  "(#{IssueStatus.table_name}.name=? or #{IssueStatus.table_name}.name=?)
                  and tracker_id=? and due_date<?" ,DEFAULT_VALUES['issue_status']['new'],DEFAULT_VALUES['issue_status']['accepted'],risks.id, Date.today]
        # añadir tipo_registro = no conformidad
        if !risks.nil?
          no_approval_open_out_of_date = project.issues.calculate(:count,:all,
                                   :include => [:tracker, :status] ,
                                   :conditions => cond.conditions)
        else
          no_approval_open_out_of_date = error_calidad
        end
        return no_approval_open_out_of_date
    end

    def calculate_no_approval_open_without_date project

        error_calidad="No existe el tracker #{DEFAULT_VALUES['trackers']['qa']}"
        risks=project.trackers.find_by_name(DEFAULT_VALUES['trackers']['qa'])
        cond = ARCondition.new
        cond << ['created_on BETWEEN ? AND ?', 0, @date]
        cond << [  "(#{IssueStatus.table_name}.name=? or #{IssueStatus.table_name}.name=?)
                and tracker_id=? and due_date IS NULL" ,DEFAULT_VALUES['issue_status']['new'],DEFAULT_VALUES['issue_status']['accepted'],risks.id]
        # añadir tipo_registro = no conformidad
        if !risks.nil?
          no_approval_open_without_date = project.issues.calculate(:count,:all,
                                   :include => [:tracker, :status] ,
                                   :conditions => cond.conditions)

        else
          no_approval_open_without_date = error_calidad
        end
        return no_approval_open_without_date
    end

    def calculate_ac_effort project
      #   Esfuerzo en nuevos requisitos CMMI_Solicitudes de cambio Aceptada, Resuelta o Cerrada
        error_requests_change="No existe el tracker #{DEFAULT_VALUES['trackers']['qa']}"

        tracker_calidad = project.trackers.find_by_name(DEFAULT_VALUES['trackers']['qa'])
        cond = ARCondition.new
        cond << ['created_on BETWEEN ? AND ?', 0, @date]
        cond << ["tracker_id=?", tracker_calidad.id]

        if !tracker_calidad.nil?
          request_change = 0.0
  #        Tareas con el tracker 'CMMI_Calidad'
          list_issues = (project.issues.find( :all,
                                            :include => [:tracker],
                                         :conditions => cond.conditions))
  #        Suma de horas de las tareas encontradas
          list_issues.each do |issue|
              request_change += issue.time_entries.sum(:hours,
                                     :include =>  :project).to_f
          end
        else
          request_change = error_requests_change
        end
      return request_change.class == Float ? request_change.to_s : request_change
    end

    def calculate_percentaje_errors project
  #   % de errores vs tareas totales del proyecto (en todos los estados)
  #      Errores en el projecto
        error_percentaje_errors="No existe el tracker #{DEFAULT_VALUES['trackers']['bug']}"
        tracker_errors=project.trackers.find_by_name(DEFAULT_VALUES['trackers']['bug'])
        if !tracker_errors.nil?
          errors = (project.issues.calculate(:count,
                                            :all,
                                            :include => [:tracker],
                                            :conditions => ["tracker_id = ?",tracker_errors.id])).to_f
        end
  #      Tareas en el proyecto
        error_percentaje_tasks="No existe el tracker #{DEFAULT_VALUES['trackers']['feature']}"
        tracker_tasks=project.trackers.find_by_name(DEFAULT_VALUES['trackers']['feature'])
        if !tracker_tasks.nil?
          tasks = (project.issues.calculate(:count, :all,
                                            :include => [:tracker],
                                            :conditions => ["tracker_id = ?",tracker_tasks.id])).to_f
        end
  #      Porcentaje
        error_percentaje_errors_tasks="No existen los trackers #{DEFAULT_VALUES['trackers']['bug']} y #{DEFAULT_VALUES['trackers']['feature']}"
        if !tracker_errors.nil? and !tracker_tasks.nil?
          #TODO division por 0 percentaje_errors= errors/(errors + tasks)
          percentaje_errors= (errors + tasks) > 0 ? (100 * (errors/(errors + tasks))).round(2) : 0.0
        else
          percentaje_errors = (tracker_errors.nil? and tracker_tasks.nil?) ? error_percentaje_errors_tasks : (tracker_errors.nil? ? error_percentaje_errors : error_percentaje_tasks)
        end
        return percentaje_errors.class == Float ? percentaje_errors.to_s + ' %' : percentaje_errors
    end

    def calculate_request_change project, project_metrics
  #   Esfuerzo en nuevos requisitos CMMI_Solicitudes de cambio Aceptada, Resuelta o Cerrada
        tracker_requests_change=project.trackers.find_by_name(DEFAULT_VALUES['trackers']['change'])
        raise CMI::Exception, l(:'cmi.cmi_change_tracker_not_available') if tracker_requests_change.nil?
        cond = ARCondition.new
        if @informe
          cond << ['created_on BETWEEN ? AND ?', 0, @date]
        end
        cond << [  "(#{IssueStatus.table_name}.name=? or #{IssueStatus.table_name}.name=?
                 or #{IssueStatus.table_name}.name=?) and tracker_id=?",
                 DEFAULT_VALUES['issue_status']['accepted'], DEFAULT_VALUES['issue_status']['resolved'], DEFAULT_VALUES['issue_status']['closed'], tracker_requests_change.id]
        request_change = 0.0
#        Tareas con el tracker 'CMMI_Solicitudes de cambio'
        list_issues = (project.issues.find( :all,
                                          :include => [:status, :tracker],
                                       :conditions => cond.conditions))
#        Suma de horas de las tareas encontradas
        list_issues.each do |issue|
            request_change += issue.time_entries.sum(:hours,
                                   :include =>  :project).to_f
        end
#        project_metrics["effort_real"] = 1.0
        request_change = (!project_metrics["effort_real"].nil? and project_metrics["effort_real"].to_f > 0.0) ?
          (100 * (request_change/project_metrics["effort_real"].to_f)).round(2) : 0.0

      return request_change.class == Float ? request_change.to_s : request_change
    end
  end
end
