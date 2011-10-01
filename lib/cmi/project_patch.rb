require_dependency 'project'
require 'dispatcher'

module CMI
  module ProjectPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will be reloaded in development
      end
    end

    module ClassMethods
      def groups
        raise CMI::NoConfigException unless Setting.plugin_redmine_cmi
        group_field = ProjectCustomField.find_by_name(Setting.plugin_redmine_cmi['field_project_group'])
        group_field && group_field.possible_values || []
      end
    end

    module InstanceMethods
      def last_report
        issues.find(:first,
                    :conditions => ['tracker_id = ? AND project_id = ?',
                                    Tracker.find_by_name(DEFAULT_VALUES['trackers']['report']),
                                    id],
                    :order => 'start_date DESC')
      end

      def report_tracker?
        trackers.find_by_name(DEFAULT_VALUES['trackers']['report']).present?
      end

      def effort_done_by_role(role, to_date)
        cond = ARCondition.new
        cond << project_condition(Setting.display_subprojects_issues?)
        cond << ['role = ?', role]
        cond << ['spent_on <= ?', to_date]
        TimeEntry.sum(:hours,
                      :include => [:project],
                      :conditions => cond.conditions)
      end

      def hr_spent(to_date)
      cond = ARCondition.new
      cond << project.project_condition(Setting.display_subprojects_issues?)
      cond << ['spent_on <= ?', to_date]
      TimeEntry.sum(:cost,
                    :include => [:project],
                    :conditions => cond.conditions)
      end

      def expenses
        issues.find(:all,
                    :conditions => ['tracker_id = ? AND project_id = ?',
                                    Tracker.find_by_name(DEFAULT_VALUES['trackers']['expense']),
                                    id])
      end
    end
  end
end

Dispatcher.to_prepare do
  Project.send(:include, CMI::ProjectPatch)
end
