require_dependency 'timelog_controller'
require 'dispatcher'

# Patches Redmine's ApplicationController dinamically. Redefines methods wich
# send error responses to clients
module TimelogControllerPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable # Send unloadable so it will be reloaded in development

      alias_method_chain :edit, :role_and_cost
      alias_method_chain :report, :profile
    end
  end

  module ClassMethods
  end

  module InstanceMethods

    def report_with_profile
      @available_criterias = { 'project' => {:sql => "#{TimeEntry.table_name}.project_id",
                                          :klass => Project,
                                          :label => :label_project},
                             'version' => {:sql => "#{Issue.table_name}.fixed_version_id",
                                          :klass => Version,
                                          :label => :label_version},
                             'category' => {:sql => "#{Issue.table_name}.category_id",
                                            :klass => IssueCategory,
                                            :label => :field_category},
                             'member' => {:sql => "#{TimeEntry.table_name}.user_id",
                                         :klass => User,
                                         :label => :label_member},
                             'tracker' => {:sql => "#{Issue.table_name}.tracker_id",
                                          :klass => Tracker,
                                          :label => :label_tracker},
                             'activity' => {:sql => "#{TimeEntry.table_name}.activity_id",
                                           :klass => TimeEntryActivity,
                                           :label => :label_activity},
                             'profile' => {:sql => "Role",
                                           :klass => Role,
                                           :label => :label_profile},
                             'issue' => {:sql => "#{TimeEntry.table_name}.issue_id",
                                         :klass => Issue,
                                         :label => :label_issue}
                           }

         # Add list and boolean custom fields as available criterias
         custom_fields = (@project.nil? ? IssueCustomField.for_all : @project.all_issue_custom_fields)
         custom_fields.select {|cf| %w(list bool).include? cf.field_format }.each do |cf|
         @available_criterias["cf_#{cf.id}"] = {:sql => "(SELECT c.value FROM #{CustomValue.table_name} c WHERE c.custom_field_id = #{cf.id} AND c.customized_type = 'Issue' AND c.customized_id = #{Issue.table_name}.id)",
                                             :format => cf.field_format,
                                             :label => cf.name}
         end if @project

         # Add list and boolean time entry custom fields
         TimeEntryCustomField.find(:all).select {|cf| %w(list bool).include? cf.field_format }.each do |cf|
           @available_criterias["cf_#{cf.id}"] = {:sql => "(SELECT c.value FROM #{CustomValue.table_name} c WHERE c.custom_field_id = #{cf.id} AND c.customized_type = 'TimeEntry' AND c.customized_id = #{TimeEntry.table_name}.id)",
                                             :format => cf.field_format,
                                             :label => cf.name}
         end

         # Add list and boolean time entry activity custom fields
         TimeEntryActivityCustomField.find(:all).select {|cf| %w(list bool).include? cf.field_format }.each do |cf|
           @available_criterias["cf_#{cf.id}"] = {:sql => "(SELECT c.value FROM #{CustomValue.table_name} c WHERE c.custom_field_id = #{cf.id} AND c.customized_type = 'Enumeration' AND c.customized_id = #{TimeEntry.table_name}.activity_id)",
                                             :format => cf.field_format,
                                             :label => cf.name}
         end

         @criterias = params[:criterias] || []
         @criterias = @criterias.select{|criteria| @available_criterias.has_key? criteria}
         @criterias.uniq!
         @criterias = @criterias[0,3]

         @columns = (params[:columns] && %w(year month week day).include?(params[:columns])) ? params[:columns] : 'month'

         retrieve_date_range

         unless @criterias.empty?
           sql_select = @criterias.collect{|criteria| @available_criterias[criteria][:sql] + " AS " + criteria}.join(', ')
           sql_group_by = @criterias.collect{|criteria| @available_criterias[criteria][:sql]}.join(', ')
           sql_condition = ''

           if @project.nil?
             sql_condition = Project.allowed_to_condition(User.current, :view_time_entries)
           elsif @issue.nil?
             sql_condition = @project.project_condition(Setting.display_subprojects_issues?)
           else
             sql_condition = "#{TimeEntry.table_name}.issue_id = #{@issue.id}"
           end

           sql = "SELECT #{sql_select}, tyear, tmonth, tweek, spent_on, SUM(hours) AS hours"
           sql << " FROM #{TimeEntry.table_name}"
           sql << " LEFT JOIN #{Issue.table_name} ON #{TimeEntry.table_name}.issue_id = #{Issue.table_name}.id"
           sql << " LEFT JOIN #{Project.table_name} ON #{TimeEntry.table_name}.project_id = #{Project.table_name}.id"
           sql << " WHERE"
           sql << " (%s) AND" % sql_condition
           sql << " (spent_on BETWEEN '%s' AND '%s')" % [ActiveRecord::Base.connection.quoted_date(@from), ActiveRecord::Base.connection.quoted_date(@to)]
           sql << " GROUP BY #{sql_group_by}, tyear, tmonth, tweek, spent_on"

           @hours = ActiveRecord::Base.connection.select_all(sql)

           @hours.each do |row|
             case @columns
             when 'year'
               row['year'] = row['tyear']
             when 'month'
               row['month'] = "#{row['tyear']}-#{row['tmonth']}"
             when 'week'
               row['week'] = "#{row['tyear']}-#{row['tweek']}"
             when 'day'
               row['day'] = "#{row['spent_on']}"
             end
           end

           @total_hours = @hours.inject(0) {|s,k| s = s + k['hours'].to_f}

           @periods = []
           # Date#at_beginning_of_ not supported in Rails 1.2.x
           date_from = @from.to_time
           # 100 columns max
           while date_from <= @to.to_time && @periods.length < 100
             case @columns
             when 'year'
               @periods << "#{date_from.year}"
               date_from = (date_from + 1.year).at_beginning_of_year
             when 'month'
               @periods << "#{date_from.year}-#{date_from.month}"
               date_from = (date_from + 1.month).at_beginning_of_month
             when 'week'
               @periods << "#{date_from.year}-#{date_from.to_date.cweek}"
               date_from = (date_from + 7.day).at_beginning_of_week
             when 'day'
               @periods << "#{date_from.to_date}"
               date_from = date_from + 1.day
             end
           end
         end

         respond_to do |format|
          format.html { render :layout => !request.xhr? }
          format.csv  { send_data(report_to_csv(@criterias, @periods, @hours), :type => 'text/csv; header=present', :filename => 'timelog.csv') }
        end
    end

    def edit_with_role_and_cost
      (render_403; return) if @time_entry && !@time_entry.editable_by?(User.current)
      @time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :user => User.current, :spent_on => User.current.today, :role => User.current.custom_values[0].value)
      @time_entry.attributes = params[:time_entry]
      @hash_cost_actual_year = (HistoryProfilesCost.find :all).group_by(&:year)[Date.today.year].group_by(&:profile)

      user_role = !@time_entry.role.nil? ? @time_entry.role : User.current.custom_values[0].value
      cost = params[:time_entry].nil? ? @time_entry.cost : (params[:time_entry][:hours].to_f * @hash_cost_actual_year["#{user_role}"].first.value.to_f)
      if params[:time_entry]
        @time_entry.update_attribute("cost", cost)
        @time_entry.update_attribute("role", user_role)
      end
      call_hook(:controller_timelog_edit_before_save, { :params => params, :time_entry => @time_entry })

      if request.post? and @time_entry.save
        flash[:notice] = l(:notice_successful_update)
        redirect_back_or_default :action => 'details', :project_id => @time_entry.project
        return
      end
    end
  end
end

Dispatcher.to_prepare do
  TimelogController.send(:include, TimelogControllerPatch)
end
