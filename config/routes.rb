ActionController::Routing::Routes.draw do |map|
  map.resources :checkpoints, :path_prefix => '/projects/:project_id/metrics', :member => { :preview => :put, :new_journal => :post }
  map.resources :expenditures, :path_prefix => '/projects/:project_id/expenses', :member => { :preview => :put, :new_journal => :post }
  map.metrics '/projects/:project_id/metrics/:action', :controller => 'metrics'
end
