# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

gem 'mocha'
require 'mocha'

def create_test_data
  # Profile cost info
  HistoryProfilesCost.new(:profile => "JP", :year => 2011, :value => 30).save!
  HistoryProfilesCost.new(:profile => "AF", :year => 2011, :value => 25).save!
  HistoryProfilesCost.new(:profile => "AP", :year => 2011, :value => 20).save!
  HistoryProfilesCost.new(:profile => "PS", :year => 2011, :value => 15).save!
  HistoryProfilesCost.new(:profile => "PJ", :year => 2011, :value => 10).save!
  HistoryProfilesCost.new(:profile => "B", :year => 2011, :value => 5).save!
  # Some users
  Time.stubs(:now).returns(Time.mktime(2011, 1, 1))
  field_user_role = UserCustomField.create(:type => "UserCustomField",
                                           :name => DEFAULT_VALUES['user_role_field'],
                                           :field_format => "list",
                                           :possible_values => ['JP', 'AF', 'AP', 'PS', 'PJ', 'B'],
                                           :regexp => "",
                                           :is_required => true,
                                           :is_for_all => false,
                                           :is_filter => false,
                                           :searchable => false,
                                           :editable => false,
                                           :default_value => nil).id
  jp = User.new(:firstname => "John",
                :lastname => "Doe",
                :language => "en",
                :admin => false,
                :mail => "jp@example.com",
                :custom_field_values => { field_user_role => "JP" })
  jp.login = "jp"
  jp.save!
  af = User.new(:firstname => "Mike",
                :lastname => "Af",
                :language => "en",
                :admin => false,
                :mail => "af@example.com",
                :custom_field_values => { field_user_role => "AF" })
  af.login = "af"
  af.save!
  ap = User.new(:firstname => "John",
                :lastname => "Ap",
                :language => "en",
                :admin => false,
                :mail => "ap@example.com",
                :custom_field_values => { field_user_role => "AP" })
  ap.login = "ap"
  ap.save!
  ps = User.new(:firstname => "John",
                :lastname => "Ps",
                :language => "en",
                :admin => false,
                :mail => "ps@example.com",
                :custom_field_values => { field_user_role => "PS" })
  ps.login = "ps"
  ps.save!
  pj = User.new(:firstname => "John",
                :lastname => "Pj",
                :language => "en",
                :admin => false,
                :mail => "pj@example.com",
                :custom_field_values => { field_user_role => "PJ" })
  pj.login = "pj"
  pj.save!
  b = User.new(:firstname => "John",
               :lastname => "B",
               :language => "en",
               :admin => false,
               :mail => "b@example.com",
               :custom_field_values => { field_user_role => "B" })
  b.login = "b"
  b.save!
  nonmember = User.new(:firstname => "Not",
                       :lastname => "Member",
                       :language => "en",
                       :admin => false,
                       :mail => "nonmember@example.com",
                       :custom_field_values => { field_user_role => "AF" })
  nonmember.login = "nonmember"
  nonmember.save!
  # Roles
  cmirole = Role.new(:name => "cmi", :permissions => [:cmi_management,
                                                      :cmi_view_metrics,
                                                      :cmi_project_info,
                                                      :cmi_add_checkpoints,
                                                      :cmi_edit_checkpoints,
                                                      :cmi_add_checkpoint_notes,
                                                      :cmi_edit_checkpoint_notes,
                                                      :cmi_edit_own_checkpoint_notes,
                                                      :cmi_view_checkpoints,
                                                      :cmi_delete_checkpoints,
                                                      :cmi_add_expenditures,
                                                      :cmi_edit_expenditures,
                                                      :cmi_add_expenditure_notes,
                                                      :cmi_edit_expenditure_notes,
                                                      :cmi_edit_own_expenditure_notes,
                                                      :cmi_view_expenditures,
                                                      :cmi_delete_expenditures])
  cmirole.save!
  Role.new(:name => "other", :permissions => []).save!
  # A project...
  Project.destroy_all
  p = Project.new(:id         => 1,
                  :identifier => "cmi",
                  :name       => "CMI test",
                  :is_public  => false,
                  :enabled_module_names => ["issue_tracking", "time_tracking", "cmiplugin"])
  p.save!
  CmiProjectInfo.create!(:project => p,
                         :scheduled_start_date    => Date.new(2011, 1, 1),
                         :scheduled_finish_date   => Date.new(2011, 7, 1),
                         :actual_start_date       => Date.new(2011, 2, 1),
                         :scheduled_qa_meetings   => 3,
                         :total_income            => 123456,
                         :scheduled_material_budget => 50,
                         :scheduled_role_effort => {
                           "JP"                   => 100,
                           "AF"                   => 200,
                           "AP"                   => 300,
                           "PS"                   => 400,
                           "PJ"                   => 500,
                           "B"                    => 600
                         })
  # Members
  [jp, af, ap, ps, pj, b].each do |user|
    m = Member.new(:user =>    user,
                   :roles =>   [cmirole],
                   :project => p).save!
  end
  # Checkpoints
  CmiCheckpoint.create!(:project               => p,
                        :author                => jp,
                        :description           => "Report upto 2/15",
                        :checkpoint_date       => Date.new(2011, 2, 15),
                        :scheduled_finish_date => Date.new(2011, 7, 1),
                        :scheduled_qa_meetings => 0,
                        :scheduled_role_effort => {
                          "JP"                 => 100,
                          "AF"                 => 300,
                          "AP"                 => 500,
                          "PS"                 => 1000,
                          "PJ"                 => 800,
                          "B"                  => 600
                        })
  CmiCheckpoint.create!(:project               => p,
                        :author                => jp,
                        :description           => "Report upto 3/15",
                        :checkpoint_date       => Date.new(2011, 3, 15),
                        :scheduled_finish_date => Date.new(2011, 8, 1),
                        :scheduled_qa_meetings => 1,
                        :scheduled_role_effort => {
                          "JP"                 => 150,
                          "AF"                 => 400,
                          "AP"                 => 600,
                          "PS"                 => 1200,
                          "PJ"                 => 1000,
                          "B"                  => 600
                        })
  # Issues
  tracker_bugs = Tracker.find_by_name("Bug").id
  tracker_features = Tracker.find_by_name("Feature").id
  10.times do |i|
    Issue.create!(:project => p,
                  :author => jp,
                  :tracker_id => tracker_features,
                  :subject => "Feature #{i}")
  end
  3.times do |i|
    Issue.create!(:project => p,
                  :author => jp,
                  :tracker_id => tracker_bugs,
                  :subject => "Bug #{i}")
  end
  # Time entries
  Date.new(2011,1,1).upto(Date.new(2011,7,1)) do |date|
    wday = Date::DAYNAMES[date.wday]
    next if ["Saturday", "Sunday"].include?(wday)
    if wday == "Monday"
      # JPs rarely work
      TimeEntry.new(:project => p,
                    :user => jp,
                    :issue => Issue.first(:conditions => ["tracker_id IN (?, ?)",
                                          tracker_features, tracker_bugs ]),
                    :spent_on => date,
                    :activity => TimeEntryActivity.first,
                    :hours => 4).save!
    end
    TimeEntry.new(:project => p,
                  :user => af,
                  :issue => Issue.first(:conditions => ["tracker_id IN (?, ?)",
                                        tracker_features, tracker_bugs ]),
                  :spent_on => date,
                  :activity => TimeEntryActivity.first,
                  :hours => 2.5).save!
    TimeEntry.new(:project => p,
                  :user => ap,
                  :issue => Issue.first(:conditions => ["tracker_id IN (?, ?)",
                                        tracker_features, tracker_bugs ]),
                  :spent_on => date,
                  :activity => TimeEntryActivity.first,
                  :hours => 4).save!
    TimeEntry.new(:project => p,
                  :user => ps,
                  :issue => Issue.first(:conditions => ["tracker_id IN (?, ?)",
                                        tracker_features, tracker_bugs ]),
                  :spent_on => date,
                  :activity => TimeEntryActivity.first,
                  :hours => 8).save!
    TimeEntry.new(:project => p,
                  :user => pj,
                  :issue => Issue.first(:conditions => ["tracker_id IN (?, ?)",
                                        tracker_features, tracker_bugs ]),
                  :spent_on => date,
                  :activity => TimeEntryActivity.first,
                  :hours => 7).save!
    TimeEntry.new(:project => p,
                  :user => b,
                  :issue => Issue.first(:conditions => ["tracker_id IN (?, ?)",
                                        tracker_features, tracker_bugs ]),
                  :spent_on => date,
                  :activity => TimeEntryActivity.first,
                  :hours => 5).save!
  end
  # TODO add some qa, risk, incidence, expense
end
