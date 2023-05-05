# frozen_string_literal: true

module RedmineJenkinsJob
  module ProjectsHelperPatch
    def project_settings_tabs
      action = {
        name: 'jenkins_job',
        controller: :jenkins_setting,
        action: :update,
        partial: 'jenkins_setting/show',
        label: :jenkins_setting,
      }

      tabs = super
      tabs << action if User.current.allowed_to?(action, @project)
      tabs
    end
  end
end

Rails.application.config.after_initialize do
  ProjectsController.send(:helper, RedmineJenkinsJob::ProjectsHelperPatch)
end
