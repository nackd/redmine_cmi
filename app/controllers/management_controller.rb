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
    if params[:selected_project_group].present?
      @projects = Project.active.all(:select => 'projects.*',
                                     :joins => :cmi_project_info,
                                     :conditions => ['cmi_project_infos.group = ?', params[:selected_project_group]],
                                     :order => :lft)
    else
      @projects = Project.active.all(:order => :lft)
    end
  end

  def get_archived_projects
    if params[:selected_project_group].present?
      @archived = Project.all(:select => 'projects.*',
                              :joins => :cmi_project_info,
                              :conditions => ["#{Project.table_name}.status = #{Project::STATUS_ARCHIVED} " +
                                              "AND cmi_project_infos.group = ?", params[:selected_project_group]],
                              :order => :lft)
    else
      @archived = Project.all(:conditions => ["#{Project.table_name}.status = #{Project::STATUS_ARCHIVED}"],
                              :order => :lft)
    end
  end
end
