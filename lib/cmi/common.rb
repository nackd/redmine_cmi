module CMI
  module Common
    class << self

      def get_customs(project, project_metrics)
        [ Setting.plugin_redmine_cmi["field_project_scheduled_start_date"],
          Setting.plugin_redmine_cmi["field_project_scheduled_finish_date"],
          # TODO drop this hardcoded role list
          Setting.plugin_redmine_cmi['field_project_scheduled_role_effort'].gsub('%{role}', "JP"),
          Setting.plugin_redmine_cmi['field_project_scheduled_role_effort'].gsub('%{role}', "AF"),
          Setting.plugin_redmine_cmi['field_project_scheduled_role_effort'].gsub('%{role}', "AP"),
          Setting.plugin_redmine_cmi['field_project_scheduled_role_effort'].gsub('%{role}', "PS"),
          Setting.plugin_redmine_cmi['field_project_scheduled_role_effort'].gsub('%{role}', "PJ"),
          Setting.plugin_redmine_cmi['field_project_scheduled_role_effort'].gsub('%{role}', "B"),
          Setting.plugin_redmine_cmi["field_project_scheduled_material_budget"],
          Setting.plugin_redmine_cmi["field_project_total_income"],
          Setting.plugin_redmine_cmi["field_project_qa_review_meetings"],
          Setting.plugin_redmine_cmi["field_project_actual_start_date"]
        ].each do |custom_field_name|
          id = ProjectCustomField.find_by_name(custom_field_name)
          project_metrics[custom_field_name] = (project.custom_values.find_by_custom_field_id(id)).value unless id.nil?
        end
        return project_metrics
      end

      def get_informe(informe, project_metrics)
        @informe = informe
        project_metrics['Fecha del informe'] = informe.start_date.to_s
        ["#{Setting.plugin_redmine_cmi['field_report_scheduled_finish_date']}",
          # TODO drop this hardcoded role list
          Setting.plugin_redmine_cmi['field_report_scheduled_role_effort'].gsub('%{role}', "JP"),
          Setting.plugin_redmine_cmi['field_report_scheduled_role_effort'].gsub('%{role}', "AF"),
          Setting.plugin_redmine_cmi['field_report_scheduled_role_effort'].gsub('%{role}', "AP"),
          Setting.plugin_redmine_cmi['field_report_scheduled_role_effort'].gsub('%{role}', "PS"),
          Setting.plugin_redmine_cmi['field_report_scheduled_role_effort'].gsub('%{role}', "PJ"),
          Setting.plugin_redmine_cmi['field_report_scheduled_role_effort'].gsub('%{role}', "B"),
          Setting.plugin_redmine_cmi['field_report_held_qa_review_meetings']
        ].each do |custom_field_name|
          id = IssueCustomField.find_by_name(custom_field_name)
          project_metrics[custom_field_name] = (informe.custom_values.find_by_custom_field_id(id)).value unless id.nil?
        end
        return [project_metrics, @informe]
      end

    end
  end
end
