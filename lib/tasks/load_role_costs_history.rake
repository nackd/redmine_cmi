require 'active_record/fixtures'
require File.expand_path(File.join(%w[.. cmi fixtures_patch]), File.dirname(__FILE__))

desc 'Load CMI role costs history. (db/fixtures/history_profiles_costs.csv)'

namespace :cmi do
  task :load_role_costs_history => :environment do
    Fixtures.create_fixtures(File.join(File.dirname(__FILE__), %w[.. .. db fixtures]), 'history_profiles_costs')
  end
end
