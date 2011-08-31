class CheckpointsController < ApplicationController
  unloadable

  menu_item :metrics
  before_filter :find_project_by_project_id, :authorize

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

  private

  def sort_column
    CmiCheckpoint.column_names.include?(params[:sort]) ? params[:sort] : "date"
  end

  def sort_direction
    %w[asc desc].include?(params[:order]) ? params[:order] : "desc"
  end
end
