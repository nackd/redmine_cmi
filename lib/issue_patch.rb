require_dependency 'issue'
require 'dispatcher'

# Patches Redmine's Issue dynamically.  Adds relationships
# Issue +has_one+ to Incident and ImprovementAction
module IssuePatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will be reloaded in development

      alias_method_chain :save_issue_with_child_records, :role_and_cost
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def save_issue_with_child_records_with_role_and_cost(params, existing_time_entry=nil)
      Issue.transaction do

        if params[:time_entry] && params[:time_entry][:hours].present? && User.current.allowed_to?(:log_time, project)
          @time_entry = existing_time_entry || TimeEntry.new
          @time_entry.role = User.current.role
          puts "Role: #{User.current.role}"
          unless User.current.role.nil? or User.current.role.empty?
            @hash_cost_actual_year = (HistoryProfilesCost.find :all).group_by(&:year)[Date.today.year].group_by(&:profile)
            @time_entry.cost = !params[:time_entry].nil? ? params[:time_entry][:hours].to_f * @hash_cost_actual_year["#{User.current.role}"].first.value.to_f : 0.0
          end
          @time_entry.project = project
          @time_entry.issue = self
          @time_entry.user = User.current
          @time_entry.spent_on = Date.today
          @time_entry.attributes = params[:time_entry]
          self.time_entries << @time_entry
        end

        if valid?
          attachments = Attachment.attach_files(self, params[:attachments])

          attachments[:files].each {|a| @current_journal.details << JournalDetail.new(:property => 'attachment', :prop_key => a.id, :value => a.filename)}
          # TODO: Rename hook
          Redmine::Hook.call_hook(:controller_issues_edit_before_save, { :params => params, :issue => self, :time_entry => @time_entry, :journal => @current_journal})
          begin
            if save
              # TODO: Rename hook
              Redmine::Hook.call_hook(:controller_issues_edit_after_save, { :params => params, :issue => self, :time_entry => @time_entry, :journal => @current_journal})
            else
              raise ActiveRecord::Rollback
            end
          rescue ActiveRecord::StaleObjectError
            attachments[:files].each(&:destroy)
            errors.add_to_base l(:notice_locking_conflict)
            raise ActiveRecord::Rollback
          end
        end
      end      
    end
  end
end

Dispatcher.to_prepare do
  Issue.send(:include, IssuePatch)
end
