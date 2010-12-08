require_dependency 'user'
require 'dispatcher'

# Patches Redmine's Issue dynamically.  Adds relationships
# Issue +has_one+ to Incident and ImprovementAction
module CMI
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
      def role
        role_field = UserCustomField.find_by_name(DEFAULT_VALUES['user_role_field'], :select => :id)
        custom_value_for(role_field.id).value rescue nil
      end

      def role=(role)
        role_field = UserCustomField.find_by_name(DEFAULT_VALUES['user_role_field'], :select => :id)
        cv = CustomValue.find_or_initialize_by_customized_type_and_custom_field_id_and_customized_id(
          'Principal',
          role_field.id,
          id)
        cv.value = role
        cv.save!
      end
    end
  end
end

Dispatcher.to_prepare do
  User.send(:include, CMI::UserPatch)
end
