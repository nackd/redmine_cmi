require_dependency 'timelog_controller'
require 'dispatcher'

# Patches Redmine's ApplicationController dinamically. Redefines methods wich
# send error responses to clients
module CMI
  module TimelogControllerPatch
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
                                             :klass => Role,
                                             :label => :label_profile}
      end
    end
  end
end

Dispatcher.to_prepare do
  TimelogController.send(:include, CMI::TimelogControllerPatch)
end
