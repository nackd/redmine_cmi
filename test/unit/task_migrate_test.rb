require File.expand_path("../test_helper", File.dirname(__FILE__))
require 'rake'

class TaskMigrateTest < ActiveSupport::TestCase
  # We are managing this ourselves
  self.use_transactional_fixtures = false

  def self.suite
    mysuite = super
    def mysuite.run(*args)
      ActiveRecord::Base.connection.transaction do
        create_old_data
        super
        raise ActiveRecord::Rollback
      end
    end
    mysuite
  end

  test "migrate project info" do
    assert_equal 0, CmiProjectInfo.count
    assert_equal 1, Project.count
    assert_equal 8, ProjectCustomField.count
    assert_equal 1, UserCustomField.count

    Rake.application.rake_require "migrate", File.expand_path("../../lib/tasks", File.dirname(__FILE__))
    Rake::Task.define_task :environment
    Rake::Task["cmi:migrate"].invoke

    info = CmiProjectInfo.first
    project = Project.first

    assert_equal 1, CmiProjectInfo.count
    assert_equal 0, ProjectCustomField.count
    assert_equal 1, UserCustomField.count

    assert_equal project, info.project
    assert_equal "One", info.group
    assert_equal Date.new(2011, 1, 1), info.scheduled_start_date
    assert_equal Date.new(2011, 7, 1), info.scheduled_finish_date
    assert_equal 1, info.scheduled_qa_meetings
    assert_equal 50000, info.total_income
    assert_equal Date.new(2011, 2, 1), info.actual_start_date
    assert_equal ({ "One" => 1000,
                    "Two" => 2000 }), info.scheduled_role_effort
  end
end
