require_dependency 'time_entry'
require 'dispatcher'

# Patches Redmine's TimeEntry dinamically. Adds callbacks to save the role and
# cost added by the plugin.
module CMI
  module TimeEntryPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable # Send unloadable so it will be reloaded in development
        before_save :update_role_and_cost
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def update_role_and_cost
        self.role = self.user.role
        @hash_cost_actual_year = (HistoryProfilesCost.find :all).group_by(&:year)[self.tyear].group_by(&:profile)
        if attribute_present?("hours") and self.role.present?
          self.cost = (self.hours.to_f * @hash_cost_actual_year["#{self.role}"].first.value.to_f)
        end
      end
    end
  end
end

Dispatcher.to_prepare do
  TimeEntry.send(:include, CMI::TimeEntryPatch)
end
