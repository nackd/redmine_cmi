require 'active_record/fixtures'
class AddUserProfiles < ActiveRecord::Migration
  def self.up
    User.all.each do |u|
      h = HistoryUserProfile.find_last_by_user_id "#{u.id}"
      u.save!
      if (!h.nil? and !u.custom_values[0].nil?)
        u.custom_values[0].update_attribute('value', h.profile)
      end
    end
    execute "update time_entries set role = (select profile from history_user_profiles where user_id = time_entries.user_id and created_on < time_entries.created_on and (finished_on = 0 or finished_on > time_entries.created_on)), cost = (CAST(hours AS decimal(10,5)) * CAST((select hour_cost from history_user_profiles where user_id = time_entries.user_id and created_on < time_entries.created_on and (finished_on = 0 or finished_on > time_entries.created_on)) AS decimal(10,5)));"
  end

  def self.down
    HistoryUserProfile.delete_all
  end
end
