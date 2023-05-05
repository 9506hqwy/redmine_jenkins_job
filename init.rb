# frozen_string_literal: true

basedir = File.expand_path('../lib', __FILE__)
libraries =
  [
    'redmine_jenkins_job/utils',
    'redmine_jenkins_job/jenkins_artifact',
    'redmine_jenkins_job/jenkins_build',
    'redmine_jenkins_job/jenkins_client',
    'redmine_jenkins_job/jenkins_job_detail',
    'redmine_jenkins_job/jenkins_job',
    'redmine_jenkins_job/projects_helper_patch',
    'redmine_jenkins_job/project_patch',
  ]

libraries.each do |library|
  require_dependency File.expand_path(library, basedir)
end

Redmine::Plugin.register :redmine_jenkins_job do
  name 'Redmine Jenkins Job plugin'
  author '9506hqwy'
  description 'This is a jenkins job operator plugin for Redmine'
  version '0.1.0'
  url 'https://github.com/9506hqwy/redmine_jenkins_job'
  author_url 'https://github.com/9506hqwy'

  project_module :jenkins_job do
    permission :view_jenkins_job, {
      jenkins_job: [:artifacts, :build, :builds, :index, :job, :output],
    }

    permission :edit_jenkins_job, {
      jenkins_job: [:exec],
    }

    permission :edit_jenkins_setting, {
      jenkins_setting: [:jobs, :update],
    }
  end

  menu :project_menu, :jenkins_job, {controller: :jenkins_job, action: :index}, caption: 'Jenkins', param: :project_id
end
