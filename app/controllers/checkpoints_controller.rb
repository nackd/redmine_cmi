class CheckpointsController < ApplicationController
  unloadable

  menu_item :metrics
  before_filter :find_project_by_project_id, :authorize
  before_filter :get_roles, :only => :new

  def index
    @limit = per_page_option
    @count = CmiCheckpoint.count
    @pages = Paginator.new self, @count, @limit, params['page']
    @offset ||= @pages.current.offset
    @sort = sort_column
    @order = sort_direction
    @checkpoints = CmiCheckpoint.all(:conditions => ['project_id = ?', @project],
                                     :order => [@sort, @order].join(' '),
                                     :offset => @offset,
                                     :limit => @limit)
  end

  def new
    @checkpoint = CmiCheckpoint.new
  end

  def create
    @checkpoint = CmiCheckpoint.new params[:checkpoint]
    @checkpoint.project_id = @project
    @checkpoint.author_id = User.current
    if @checkpoint.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => :index
    else
      get_roles
      render :action => 'new'
    end
  end

  private

  def sort_column
    CmiCheckpoint.column_names.include?(params[:sort]) ? params[:sort] : "checkpoint_date"
  end

  def sort_direction
    %w[asc desc].include?(params[:order]) ? params[:order] : "desc"
  end

  def get_roles
    @roles = User.roles
  end
end
