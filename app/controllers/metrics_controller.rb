class MetricsController < ApplicationController
  unloadable

  menu_item :metrics
  before_filter :find_project_by_project_id, :authorize
  before_filter :get_roles

  helper :cmi, :view

  def show
    begin
      @checkpoints = @project.cmi_checkpoints.find(:all,
                                                   :order => 'checkpoint_date DESC',
                                                   :limit => (2 if params[:metrics].nil?),
                                                   :include => :cmi_checkpoint_efforts)
      @metrics = @checkpoints.collect { |checkpoint| CMI::CheckpointMetrics.new checkpoint }
      @metrics.insert 0, CMI::ProjectMetrics.new(@project)
      raise CMI::Exception, I18n.t(:'cmi.no_project_info', :project => @project) if @project.cmi_project_info.nil?
      raise CMI::Exception, I18n.t(:'cmi.no_actual_start_date', :project => @project) if @project.cmi_project_info.actual_start_date.nil?
      raise CMI::Exception, I18n.t(:'cmi.cmi_no_checkpoints_found', :project => @project) if @checkpoints.empty?
      respond_to do |format|
          format.html { render :layout => !request.xhr? }
          format.js { render(:update) {|page| page.replace_html "tab-content-metrics", :partial => 'metrics/show_metrics'} }
      end
    rescue CMI::Exception => e
      flash[:error] = e.message
    end
  end

  def info
    @cmi_project_info = CmiProjectInfo.find_by_project_id @project.id, :include => :cmi_project_efforts
    unless @cmi_project_info
      @cmi_project_info = CmiProjectInfo.new :project_id => @project.id
    end
    if request.post?
      @cmi_project_info.attributes = params[:cmi_project_info]
      flash[:notice] = l(:notice_successful_update) if @cmi_project_info.save
    end
  end

  private

  def get_roles
    @roles = User.roles
  end
end
