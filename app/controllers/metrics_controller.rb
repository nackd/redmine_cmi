class MetricsController < ApplicationController
  unloadable

  menu_item :metrics
  before_filter :find_project_by_project_id, :authorize
  before_filter :get_roles
  before_filter :obtain_profile_costs, :only => :show

  helper :cmi

  def show
    begin
      @checkpoints = @project.cmi_checkpoints.find(:all,
                                                   :order => 'checkpoint_date DESC',
                                                   :limit => (2 if params[:metrics].nil?))
      @metrics = @checkpoints.collect { |checkpoint| CMI::CheckpointMetrics.new checkpoint }
      @metrics.insert 0, CMI::ProjectMetrics.new(@project)
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
    @cmi_project_info = CmiProjectInfo.find_or_initialize_by_project_id @project.id
    if request.post?
      @cmi_project_info.attributes= params[:cmi_project_info]
      flash[:notice] = l(:notice_successful_update) if @cmi_project_info.save
    end
  end

  private

  def obtain_profile_costs
    current_year_costs = (HistoryProfilesCost.find :all).group_by(&:year)[Date.today.year]
    @hash_cost_actual_year = current_year_costs && current_year_costs.group_by(&:profile)
  end

  def get_roles
    @roles = User.roles
  end
end
