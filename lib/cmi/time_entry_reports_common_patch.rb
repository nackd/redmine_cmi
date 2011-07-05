require_dependency 'time_entry_reports_controller' if File.exists?("#{RAILS_ROOT}/app/controllers/time_entry_reports_controller.rb")
require_dependency 'timelog_controller' if File.exists?("#{RAILS_ROOT}/app/controllers/timelog_controller.rb")
require 'dispatcher'

# Patches Redmine's ApplicationController dinamically. Redefines methods wich
# send error responses to clients
module CMI
  module TimeEntryReportsCommonPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will be reloaded in development
        before_filter :load_profile_criteria, :only => [:report]
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def load_profile_criteria
        @available_criterias['profile'] = {:sql => "Role",
                                           :label => :label_profile}
      end
    end
  end
end

Dispatcher.to_prepare do
  TimeEntryReportsController.send(:include, CMI::TimeEntryReportsCommonPatch) if File.exists?("#{RAILS_ROOT}/app/controllers/time_entry_reports_controller.rb")
  TimelogController.send(:include, CMI::TimeEntryReportsCommonPatch) if File.exists?("#{RAILS_ROOT}/app/controllers/timelog_controller.rb")
end
