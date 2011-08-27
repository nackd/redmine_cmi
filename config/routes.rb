ActionController::Routing::Routes.draw do |map|
  map.metrics '/projects/:project_id/metrics/:action', :controller => 'metrics'
end
