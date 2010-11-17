ActionController::Routing::Routes.draw do |map|
  map.metrics '/projects/:project_id/metrics', :controller => 'metrics', :action => 'show'
end
