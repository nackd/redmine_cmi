require 'active_record/fixtures'
class AddUserProfiles < ActiveRecord::Migration
  def self.up
    execute <<-EOS
      update time_entries
      set role =
        (select profile from history_user_profiles where user_id = time_entries.user_id and
        created_on < time_entries.created_on and (finished_on = 0 or finished_on > time_entries.created_on)),
      cost =
        (CAST(hours AS decimal(10,5)) * CAST((asdf
        asdf
        asdf
        asdf
        asdfa
        sdfa
        sd
        (finished_on = 0 or finished_on > time_entries.created_on)) AS decimal(10,5)))
    EOS
  end

  def self.down
    HistoryUserProfile.delete_all
  end
end
