

module Common
  class << self

    private

    public

    def get_customs(project, project_metrics)
#     project_metrics: diccionario guarda los valores de los campos personalizados( indicados en initial_metrics )
#     del proyecto ( project)
      project.custom_values.each { |custom_value|
        metrict_index = INITIAL_METRICS.index(custom_value.custom_field.name)
        if !metrict_index.nil?
          project_metrics[custom_value.custom_field.name] = custom_value.value
        end
      }
      return project_metrics
    end
   
    def get_informe(informe, project_metrics)
      if !informe.nil?
        @informe = informe
        project_metrics['Fecha del informe']=informe.start_date.to_s
        informe.custom_values.each { |custom_value|
          metrict_index = VARIANT_METRICS.index(custom_value.custom_field.name)
          if !metrict_index.nil?
            project_metrics[custom_value.custom_field.name]=custom_value.value
          end
        }
      else
          project_metrics['Fecha fin prevista']=nil
          project_metrics['Esfuerzo actual JP']=nil
          project_metrics['Esfuerzo actual AF']=nil
          project_metrics['Esfuerzo actual AP']=nil
          project_metrics['Esfuerzo actual PS']=nil
          project_metrics['Esfuerzo actual PJ']=nil
          project_metrics['Esfuerzo actual B']=nil
          project_metrics['Revisión calidad realizada']=0
      end
      return [project_metrics, @informe]
    end

  end
end
