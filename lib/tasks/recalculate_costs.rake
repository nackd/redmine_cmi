desc 'Recalculate costs associated to time entries (according to user roles)'

namespace :cmi do
  task :recalculate_costs => :environment do
    ActiveRecord::Base.connection.execute <<-EOS
      update time_entries set role = (select profile from history_user_profiles
        where user_id = time_entries.user_id
        and created_on <= time_entries.spent_on
        and (finished_on is NULL or finished_on >= time_entries.spent_on))
    EOS
    ActiveRecord::Base.connection.execute <<-EOS
      update time_entries set cost = (CAST(hours AS decimal(10,5))
        * CAST((select value from history_profiles_costs where profile = time_entries.role
                and year = time_entries.tyear) AS decimal(10,5)))
    EOS
  end
end