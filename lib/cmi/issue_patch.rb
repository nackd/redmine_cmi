require_dependency 'issue'
require 'dispatcher'

# Patches Redmine's Issue dynamically.  Adds relationships
# Issue +has_one+ to Incident and ImprovementAction
module CMI
  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will be reloaded in development
     end
    end

    module ClassMethods
    end

    module InstanceMethods
    end
  end
end

Dispatcher.to_prepare do
  Issue.send(:include, CMI::IssuePatch)
end
