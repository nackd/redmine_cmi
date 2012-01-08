desc 'Migrate data from version 0.9.4.1 or previous'

namespace :cmi do
  task :migrate => :environment do
    conf_file = open(File.expand_path("../../config/migrate.yml", File.dirname(__FILE__)))
    conf = YAML.load(conf_file)

    group_field = ProjectCustomField.find_by_name(conf["project_custom_fields"]["group"])
    scheduled_start_date_field = ProjectCustomField.find_by_name(conf["project_custom_fields"]["scheduled_start_date"])
    scheduled_finish_date_field = ProjectCustomField.find_by_name(conf["project_custom_fields"]["scheduled_finish_date"])
    scheduled_qa_meetings_field = ProjectCustomField.find_by_name(conf["project_custom_fields"]["scheduled_qa_meetings"])
    total_income_field = ProjectCustomField.find_by_name(conf["project_custom_fields"]["total_income"])
    actual_start_date_field = ProjectCustomField.find_by_name(conf["project_custom_fields"]["actual_start_date"])
    scheduled_role_effort_fields = User.roles.reduce({}) { |ac, role|
      ac.merge!({ role => ProjectCustomField.find_by_name(conf["project_custom_fields"]["scheduled_role_effort"].gsub('{{role}}', role)) })
    }

    ActiveRecord::Base.transaction do
      Project.find_each(:batch_size => 50,
                        :joins => :enabled_modules,
                        :conditions => "enabled_modules.name = 'cmiplugin'") do |project|
        scheduled_role_effort = scheduled_role_effort_fields.reduce({}) { |ac, field|
          ac.merge!({ field.first => (begin project.custom_value_for(field.last).value rescue 0 end) })
        }
        CmiProjectInfo.create!(:project => project,
                               :total_income => project.custom_value_for(total_income_field).value,
                               :actual_start_date => project.custom_value_for(actual_start_date_field).value,
                               :scheduled_start_date => project.custom_value_for(scheduled_start_date_field).value,
                               :scheduled_finish_date => project.custom_value_for(scheduled_finish_date_field).value,
                               :scheduled_qa_meetings => project.custom_value_for(scheduled_qa_meetings_field).value,
                               :scheduled_role_effort => scheduled_role_effort,
                               :group => project.custom_value_for(group_field).value)
      end

      group_field.destroy
      scheduled_start_date_field.destroy
      scheduled_finish_date_field.destroy
      scheduled_qa_meetings_field.destroy
      total_income_field.destroy
      actual_start_date_field.destroy
      scheduled_role_effort_fields.each_value { |field| field.destroy }
    end
  end
end
