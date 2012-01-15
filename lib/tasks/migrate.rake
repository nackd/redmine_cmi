desc 'Migrate data from version 0.9.4.1 or previous'

namespace :cmi do
  task :migrate => :environment do
    conf_file = open(File.expand_path("../../config/migrate.yml", File.dirname(__FILE__)))
    conf = YAML.load(conf_file)

    # Project custom fields
    project_group_field = ProjectCustomField.find_by_name(conf["project_custom_fields"]["group"])
    project_scheduled_start_date_field = ProjectCustomField.find_by_name(conf["project_custom_fields"]["scheduled_start_date"])
    project_scheduled_finish_date_field = ProjectCustomField.find_by_name(conf["project_custom_fields"]["scheduled_finish_date"])
    project_scheduled_qa_meetings_field = ProjectCustomField.find_by_name(conf["project_custom_fields"]["scheduled_qa_meetings"])
    project_total_income_field = ProjectCustomField.find_by_name(conf["project_custom_fields"]["total_income"])
    project_actual_start_date_field = ProjectCustomField.find_by_name(conf["project_custom_fields"]["actual_start_date"])
    project_scheduled_role_effort_fields = User.roles.reduce({}) { |ac, role|
      ac.merge!({ role => ProjectCustomField.find_by_name(conf["project_custom_fields"]["scheduled_role_effort"].gsub('{{role}}', role)) })
    }

    # Reports
    report_tracker = Tracker.find_by_name(conf["reports"]["tracker"])
    report_held_qa_meetings_field = IssueCustomField.find_by_name(conf["reports"]["custom_fields"]["held_qa_meetings"])
    report_scheduled_finish_date_field = IssueCustomField.find_by_name(conf["reports"]["custom_fields"]["scheduled_finish_date"])
    report_scheduled_role_effort_fields = User.roles.reduce({}) { |ac, role|
      ac.merge!({ role => IssueCustomField.find_by_name(conf["reports"]["custom_fields"]["scheduled_role_effort"].gsub('{{role}}', role)) })
    }

    ActiveRecord::Base.transaction do
      # Projects
      Project.find_each(:batch_size => 50,
                        :joins => :enabled_modules,
                        :conditions => "enabled_modules.name = 'cmiplugin'") do |project|
        project_scheduled_role_effort = project_scheduled_role_effort_fields.reduce({}) { |ac, field|
          ac.merge!({ field.first => (begin project.custom_value_for(field.last).value rescue 0 end) })
        }
        CmiProjectInfo.create!(:project => project,
                               :total_income => project.custom_value_for(project_total_income_field).value,
                               :actual_start_date => project.custom_value_for(project_actual_start_date_field).value,
                               :scheduled_start_date => project.custom_value_for(project_scheduled_start_date_field).value,
                               :scheduled_finish_date => project.custom_value_for(project_scheduled_finish_date_field).value,
                               :scheduled_qa_meetings => project.custom_value_for(project_scheduled_qa_meetings_field).value,
                               :scheduled_role_effort => project_scheduled_role_effort,
                               :group => project.custom_value_for(project_group_field).value)
      end

      project_group_field.destroy
      project_scheduled_start_date_field.destroy
      project_scheduled_finish_date_field.destroy
      project_scheduled_qa_meetings_field.destroy
      project_total_income_field.destroy
      project_actual_start_date_field.destroy
      project_scheduled_role_effort_fields.each_value { |field| field.destroy }

      # Reports
      unless report_tracker.nil?
        Issue.find_each(:batch_size => 50,
                        :conditions => ["tracker_id = ?", report_tracker.id]) do |report|
          report_scheduled_role_effort = report_scheduled_role_effort_fields.reduce({}) { |ac, field|
            ac.merge!({ field.first => (begin report.custom_value_for(field.last).value rescue 0 end) })
          }
          checkpoint = CmiCheckpoint.create!(:project => report.project,
                                             :author => User.anonymous,
                                             :description => report.description.blank? ? report.subject : report.description,
                                             :checkpoint_date => report.start_date,
                                             :scheduled_finish_date => report.custom_value_for(report_scheduled_finish_date_field).value,
                                             :held_qa_meetings => report.custom_value_for(report_held_qa_meetings_field).value,
                                             :scheduled_role_effort => report_scheduled_role_effort)
          report.journals.each do |journal|
            journal.journalized = checkpoint
            journal.save!
          end
          Issue.destroy(report.id) # report.destroy would remove the journal
        end
        report_held_qa_meetings_field.destroy
        report_scheduled_finish_date_field.destroy
        report_scheduled_role_effort_fields.each_value { |field| field.destroy }
        report_tracker.destroy
      end
    end
  end
end
