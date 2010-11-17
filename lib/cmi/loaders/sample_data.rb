module CMI
  module Loaders
    module SampleData
      class << self
        # Loads the cmi sample data
        # Raises a RecordNotSaved exception if something goes wrong
        def load
            # Trackers
            Tracker.create!(:name => DEFAULT_VALUES['tracker']['bug'],     :is_in_chlog => true,  :is_in_roadmap => false)
            Tracker.create!(:name => DEFAULT_VALUES['tracker']['feature'],     :is_in_chlog => true,  :is_in_roadmap => true)
            Tracker.create!(:name => DEFAULT_VALUES['tracker']['support'],     :is_in_chlog => false,  :is_in_roadmap => false)
            Tracker.create!(:name => DEFAULT_VALUES['tracker']['request'],     :is_in_chlog => true,  :is_in_roadmap => true)
            Tracker.create!(:name => DEFAULT_VALUES['tracker']['quality'],     :is_in_chlog => true,  :is_in_roadmap => true)
            Tracker.create!(:name => DEFAULT_VALUES['tracker']['risk'],     :is_in_chlog => true,  :is_in_roadmap => true)
            Tracker.create!(:name => DEFAULT_VALUES['tracker']['incidence'],     :is_in_chlog => true,  :is_in_roadmap => true)
            Tracker.create!(:name => DEFAULT_VALUES['tracker']['budget'],     :is_in_chlog => true,  :is_in_roadmap => true)
            Tracker.create!(:name => DEFAULT_VALUES['tracker']['inform'],     :is_in_chlog => true,  :is_in_roadmap => true)

            # Issue statuses
            IssueStatus.create!(:name => DEFAULT_VALUES['issue_status']['new'], :is_closed => false, :is_default => true)
            IssueStatus.create!(:name => DEFAULT_VALUES['issue_status']['in_progress'], :is_closed => false, :is_default => false)
            IssueStatus.create!(:name => DEFAULT_VALUES['issue_status']['resolved'], :is_closed => false, :is_default => false)
            IssueStatus.create!(:name => DEFAULT_VALUES['issue_status']['feedback'], :is_closed => false, :is_default => false)
            IssueStatus.create!(:name => DEFAULT_VALUES['issue_status']['closed'], :is_closed => true, :is_default => false)
            IssueStatus.create!(:name => DEFAULT_VALUES['issue_status']['rejected'], :is_closed => true, :is_default => false)
            IssueStatus.create!(:name => DEFAULT_VALUES['issue_status']['accepted'], :is_closed => false, :is_default => false)
            IssueStatus.create!(:name => DEFAULT_VALUES['issue_status']['approval'], :is_closed => false, :is_default => false)

            # Enumerations
            IssuePriority.create!(:name => DEFAULT_VALUES['priority']['lowest'])
            IssuePriority.create!(:name => DEFAULT_VALUES['priority']['low'])
            IssuePriority.create!(:name => DEFAULT_VALUES['priority']['normal'], :is_default => true)
            IssuePriority.create!(:name => DEFAULT_VALUES['priority']['high'])
            IssuePriority.create!(:name => DEFAULT_VALUES['priority']['urgent'])
            IssuePriority.create!(:name => DEFAULT_VALUES['priority']['immediate'])
        end
      end
    end
  end
end
