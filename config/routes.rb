ActionController::Routing::Routes.draw do |map|
  map.resources :checkpoints,
                :path_prefix => '/projects/:project_id/metrics',
                :member => { :new_journal => :post, :edit_journal => [:get, :post] },
                :collection => { :preview => :put }
  map.resources :expenditures,
                :path_prefix => '/projects/:project_id/metrics',
                :member => { :new_journal => :post, :edit_journal => [:get, :post] },
                :collection => { :preview => :put }
  map.metrics '/projects/:project_id/metrics/:action', :controller => 'metrics'
  map.management '/management/:action', :controller => 'management'
  map.cost_history '/admin/cost_history', :controller => 'admin', :action => 'cost_history'
end
