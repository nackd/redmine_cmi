class ManagementController < ApplicationController
  unloadable

  before_filter :set_menu_item
  before_filter :authorize_global, :get_groups
  before_filter :get_roles, :only => :groups

  def status
    get_active_projects
    render :layout => !request.xhr?
  end

  def projects
    get_active_projects
    get_archived_projects
    render :layout => !request.xhr?
  end

  def groups
    group_metrics = CMI::GroupMetrics.new
    @metrics = group_metrics.metrics
    @total_cm = group_metrics.total_cm
    @total_deviation_percent = group_metrics.total_deviation_percent
  end

  private

  def set_menu_item
    self.class.menu_item params['action'].to_sym
  end

  def get_groups
    @groups = Project.groups
  end

  def get_roles
    @roles = User.roles
  end

  def get_active_projects
    @projects = Project.active.all(:order => :lft)
    if params[:selected_project_group].present?
      group_field = ProjectCustomField.find_by_name(DEFAULT_VALUES['project_group_field'])
      @projects = @projects.select do |p|
        if p.custom_value_for(group_field)
          p.custom_value_for(group_field).value == params[:selected_project_group]
        end
      end
    end
    @last_report = {}
  end

  def get_archived_projects
    @archived = Project.find(:all,
                             :conditions => ["#{Project.table_name}.status = #{Project::STATUS_ARCHIVED}"],
                             :order => :lft)
    if params[:selected_project_group].present?
      group_field = ProjectCustomField.find_by_name(DEFAULT_VALUES['project_group_field'])
      @archived = @archived.select{ |p| p.custom_value_for(group_field).value == params[:selected_project_group] }
    end
    @last_archived_report = {}
  end
end
