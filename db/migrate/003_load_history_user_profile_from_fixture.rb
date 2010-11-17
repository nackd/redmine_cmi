require 'active_record/fixtures'

class LoadHistoryUserProfileFromFixture < ActiveRecord::Migration
  def self.up
    down
    Fixtures.create_fixtures("#{File.dirname(__FILE__)}/../fixtures", 'history_user_profiles')
  end

  def self.down
    HistoryUserProfile.delete_all
  end
end
