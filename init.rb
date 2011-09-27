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
require 'cmi/journal_observer_patch'

Redmine::Plugin.register :redmine_cmi do
  name :'cmi.plugin_name'
  author 'Emergya Consultoría'
  description :'cmi.plugin_description'
  version '0.9.4.1'

  settings :default => { }

  requires_redmine :version_or_higher => '1.0.0'
  project_module :cmiplugin do
    permission :cmi_management, { :management => [:status, :projects, :groups] }

    permission :cmi_view_metrics, { :metrics => :show }
    permission :cmi_project_info, { :metrics => :info }

    permission :cmi_add_checkpoints, { :checkpoints => [:new, :create, :preview] }
    permission :cmi_edit_checkpoints, { :checkpoints => [:edit, :update, :preview, :new_journal] }
    permission :cmi_add_checkpoint_notes, { :checkpoints => [:edit, :update, :preview, :new_journal] }
    permission :cmi_edit_checkpoint_notes, { :checkpoints => [:preview, :edit_journal] }
    permission :cmi_edit_own_checkpoint_notes, { :checkpoints => [:preview, :edit_journal] }
    permission :cmi_view_checkpoints, { :checkpoints => [:index, :show] }
    permission :cmi_delete_checkpoints, { :checkpoints => :destroy }

    permission :cmi_add_expenditures, { :expenditures => [:new, :create, :preview] }
    permission :cmi_edit_expenditures, { :expenditures => [:edit, :update, :preview, :new_journal] }
    permission :cmi_add_expenditure_notes, { :expenditures => [:edit, :update, :preview, :new_journal] }
    permission :cmi_edit_expenditure_notes, { :expenditures => [:preview, :edit_journal] }
    permission :cmi_edit_own_expenditure_notes, { :expenditures => [:preview, :edit_journal] }
    permission :cmi_view_expenditures, { :expenditures => [:index, :show] }
    permission :cmi_delete_expenditures, { :expenditures => :destroy }
  end

  menu :project_menu, :metrics, { :controller => 'metrics', :action => 'show' },
       :caption => :'cmi.caption_metrics',
       :after => :settings,
       :param => :project_id

  menu :top_menu, :cmi, { :controller => 'management', :action => 'projects'},
       :caption => 'CMI',
       :if => Proc.new { User.current.allowed_to?(:cmi_management, nil, :global => true) }

  menu :scoreboard_menu, :projects, { :controller => 'management', :action => 'projects' },
       :caption => :'cmi.caption_projects'

  menu :scoreboard_menu, :status, { :controller => 'management', :action => 'status' },
       :caption => :'cmi.caption_status'

  menu :scoreboard_menu, :groups, { :controller => 'management', :action => 'groups' },
       :caption => :'cmi.caption_groups'

  menu :admin_menu, :'cmi.label_cost_history', { :controller => 'admin', :action => 'cost_history' },
       :html => { :class => 'issue_statuses' },
       :caption => :'cmi.label_cost_history'
end
