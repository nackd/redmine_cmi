require_dependency 'users_helper'
require 'dispatcher'

# Patches Redmine's ApplicationController dinamically. Redefines methods wich
# send error responses to clients
module UsersHelperPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable  # Send unloadable so it will be reloaded in development

      alias_method_chain :user_settings_tabs, :profile_history
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def user_settings_tabs_with_profile_history
      tabs = [{:name => 'general', :partial => 'users/general', :label => :label_general},
            {:name => 'memberships', :partial => 'users/memberships', :label => :label_project_plural},
            {:name => 'profile_history', :partial => 'users/profile', :label => :'cmi.label_profile_history'}
            ]
      if Group.all.any?
        tabs.insert 1, {:name => 'groups', :partial => 'users/groups', :label => :label_group_plural}
      end
      tabs
    end
  end
end

Dispatcher.to_prepare do
  UsersHelper.send(:include, UsersHelperPatch)
end
