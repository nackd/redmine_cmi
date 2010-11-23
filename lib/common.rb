module Common
  class << self

    def get_customs(project, project_metrics)
      INITIAL_METRICS.each do |custom_field_name|
        id = ProjectCustomField.find_by_name(custom_field_name)
        project_metrics[custom_field_name] = (project.custom_values.find_by_custom_field_id(id)).value unless id.nil?
      end
      return project_metrics
    end
   
    def get_informe(informe, project_metrics)
      @informe = informe
      project_metrics['Fecha del informe']=informe.start_date.to_s
      VARIANT_METRICS.each do |custom_field_name|
        id = IssueCustomField.find_by_name(custom_field_name)
        project_metrics[custom_field_name] = (informe.custom_values.find_by_custom_field_id(id)).value unless id.nil?
      end
      return [project_metrics, @informe]
    end

  end
end
