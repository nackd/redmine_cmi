require 'active_record/fixtures'
require File.expand_path(File.join(%w[.. cmi fixtures_patch]), File.dirname(__FILE__))

desc 'Load CMI user role history. (db/fixtures/history_user_profiles.csv)'

namespace :cmi do
  task :load_user_role_history => :environment do
    Fixtures.create_fixtures(File.join(File.dirname(__FILE__), %w[.. .. db fixtures]), 'history_user_profiles')

    User.all.each do |u|
      h = HistoryUserProfile.find(:first,
                                  :conditions => { :user_id => u.id},
                                  :order => 'created_on DESC')
      u.role = h.profile unless h.nil?
    end
  end
end
