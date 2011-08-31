ActionController::Routing::Routes.draw do |map|
  map.resources :checkpoints, :path_prefix => '/projects/:project_id/metrics'
  map.metrics '/projects/:project_id/metrics/:action', :controller => 'metrics'
end
