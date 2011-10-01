Dir["#{File.dirname(__FILE__)}/config/initializers/**/*.rb"].sort.each do |initializer|
  Kernel.load(initializer)
end

require 'redmine'
require 'cmi/scoreboard_menu_helper_patch'
require 'cmi/time_entry_patch'
require 'cmi/time_entry_reports_common_patch'
require 'cmi/user_patch'
require 'cmi/users_helper_patch'
require 'cmi/project_patch'

Redmine::Plugin.register :redmine_cmi do
  name :'cmi.plugin_name'
  author 'Emergya Consultoría'
  description :'cmi.plugin_description'
  version '0.9.4.1'

  settings :partial => 'cmi'

  requires_redmine :version_or_higher => '1.0.0'
  project_module :cmiplugin do
  #     permission :view_cmi, {:cmi => [:projects, :groups, :show]}
        permission :view_metrics, {:metrics => [:show]}
  end

  menu :project_menu, :metrics, {:controller => 'metrics', :action => 'show' }, :caption => :'cmi.caption_metrics', :after => :settings, :param => :project_id
  menu :top_menu, :cmi, {:controller => 'management', :action => 'projects'}, :caption => 'CMI', :if => Proc.new { User.current.admin? }
  menu :scoreboard_menu, :projects, {:controller => 'management', :action => 'projects' }, :caption => :'cmi.caption_projects'
  menu :scoreboard_menu, :status, {:controller => 'management', :action => 'status' }, :caption => :'cmi.caption_status'
  menu :scoreboard_menu, :groups, {:controller => 'management', :action => 'groups' }, :caption => :'cmi.caption_groups'
  menu :admin_menu, :'cmi.label_cost_history', {:controller => 'admin', :action => 'cost_history'}, :html => {:class => 'issue_statuses'}, :caption => :'cmi.label_cost_history'
end
