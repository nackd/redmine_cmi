class CheckpointsController < ApplicationController
  unloadable

  menu_item :metrics
  before_filter :find_project_by_project_id, :authorize
  before_filter :get_roles, :only => [:new, :edit, :show]
  before_filter :find_checkpoint, :only => [:show, :edit, :update]

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

  def show
  end

  def edit
  end

  def update
    @checkpoint.attributes = params[:checkpoint]
    if @checkpoint.save
      flash[:notice] = l(:notice_successful_update)
      redirect_back_or_default({:action => 'show', :id => @checkpoint})
    else
      get_roles
      render :action => 'edit'
    end
  end

  private

  def find_checkpoint
    @checkpoint = CmiCheckpoint.find params[:id]
    unless @checkpoint.project_id == @project.id
      deny_access
      return
    end
  end

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
