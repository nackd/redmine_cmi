require_dependency 'user'
require 'dispatcher'

# Patches Redmine's Issue dynamically.  Adds relationships
# Issue +has_one+ to Incident and ImprovementAction
module UserPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will be reloaded in development

      has_many :history_user_profiles, :dependent => :destroy
    end
  end

  module ClassMethods
    def roles
      role_field = UserCustomField.find_by_name(DEFAULT_VALUES['user_role_field'])
      role_field.possible_values
    end
  end

  module InstanceMethods
  end
end

Dispatcher.to_prepare do
  User.send(:include, UserPatch)
end
