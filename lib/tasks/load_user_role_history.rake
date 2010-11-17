require 'active_record/fixtures'

desc 'Load CMI user role history. (db/fixtures/history_user_profiles.csv)'

namespace :cmi do
  task :load_user_role_history => :environment do
    Fixtures.create_fixtures(File.join(File.dirname(__FILE__), %w[.. .. db fixtures]), 'history_user_profiles')
    ActiveRecord::Base.connection.execute 'update history_user_profiles set finished_on = null where finished_on = 0'

    User.all.each do |u|
      h = HistoryUserProfile.find(:first,
                                  :conditions => { :user_id => u.id},
                                  :order => 'created_on DESC')
      u.role = h.profile unless h.nil?
    end
  end
end
