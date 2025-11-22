# frozen_string_literal: true

class ChangeMonitoringJobsLimitInSettings < RedmineJenkinsJob::Utils::Migration
  def up
    change_column(:jenkins_settings, :monitoring_jobs, :text)
  end

  def down
    change_column(:jenkins_settings, :monitoring_jobs, :string)
  end
end
