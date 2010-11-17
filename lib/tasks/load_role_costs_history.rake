require 'active_record/fixtures'

desc 'Load CMI role costs history. (db/fixtures/history_profiles_costs.csv)'

namespace :cmi do
  task :load_role_costs_history => :environment do
    Fixtures.create_fixtures(File.join(File.dirname(__FILE__), %w[.. .. db fixtures]), 'history_profiles_costs')
  end
end
