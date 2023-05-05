# frozen_string_literal: true

require 'webmock'
require File.expand_path('../../test_helper', __FILE__)

class JenkinsSettingControllerTest < Redmine::ControllerTest
  include Redmine::I18n
  include WebMock::API

  fixtures :email_addresses,
           :member_roles,
           :members,
           :projects,
           :roles,
           :users,
           :jenkins_settings

  def setup
    @request.session[:user_id] = 2

    role = Role.find(1)
    role.add_permission!(:edit_jenkins_setting)
  end

  def test_jobs_folder
    WebMock.enable!

    project = Project.find(5)
    project.enable_module!(:jenkins_job)

    query = RedmineJenkinsJob::Utils.job_query
    stub_request(:get, "https://127.0.0.1:8080/test/api/json?#{query}").
      to_return(body: '{"jobs": [{"_class": "com.cloudbees.hudson.plugins.folder.Folder", "name": "folder", "url": "https://jenkins:8080/job/test/job/folder/" }], "url": "https://jenkins:8080/job/test/"}')

    get :jobs, params: {
      project_id: project.id,
      folder_path: 'test/'
    }

    assert_response :success
    assert_select 'tr.jenkins-folder'
    assert_select 'span.expander'
    assert_select 'span.icon-folder'
    assert_select 'span#count-job-795910a0934fc2e0f30fe2806598d683'
  ensure
    WebMock.disable!
  end

  def test_jobs_job
    WebMock.enable!

    project = Project.find(5)
    project.enable_module!(:jenkins_job)

    query = RedmineJenkinsJob::Utils.job_query
    stub_request(:get, "https://127.0.0.1:8080/test/api/json?#{query}").
      to_return(body: '{"jobs": [{"_class": "hudson.model.FreeStyleBuild", "name": "folder", "url": "https://jenkins:8080/job/test/job/job1/" }], "url": "https://jenkins:8080/job/test/"}')

    get :jobs, params: {
      project_id: project.id,
      folder_path: 'test/'
    }

    assert_response :success
    assert_select 'tr.jenkins-job'
    assert_select 'span.icon-file'
    assert_select 'input#toggle-job-92796b47818efa62c062f477cfccb95b'
  ensure
    WebMock.disable!
  end

  def test_update_create
    WebMock.enable!

    project = Project.find(1)
    project.enable_module!(:jenkins_job)

    stub_request(:head, 'https://127.0.0.1:8080/api/json')

    put :update, params: {
      project_id: project.id,
      enable: true,
      url: 'https://127.0.0.1:8080/',
      link_url: 'https://jenkins:8080/',
      skip_ssl_verify: false,
      username: 'admin',
      secret: 'token',
      monitoring_jobs: ['A']
    }

    assert_redirected_to "/projects/#{project.identifier}/settings/jenkins_job"
    assert_not_nil flash[:notice]
    assert_nil flash[:error]

    project.reload
    assert_equal 'https://127.0.0.1:8080/', project.jenkins_setting.url
    assert_equal 'https://jenkins:8080/', project.jenkins_setting.link_url
    assert_equal false, project.jenkins_setting.skip_ssl_verify
    assert_equal 'admin', project.jenkins_setting.username
    assert_equal 'token', project.jenkins_setting.secret
    assert_equal 1, project.jenkins_setting.monitoring_jobs.length
    assert_includes project.jenkins_setting.monitoring_jobs, 'A'
  ensure
    WebMock.disable!
  end

  def test_update_deny_permission
    project = Project.find(2)
    project.enable_module!(:jenkins_job)

    put :update, params: {
      project_id: project.id,
      enable: true,
      url: 'https://127.0.0.1:8080/',
      link_url: 'https://jenkins:8080/',
      skip_ssl_verify: false,
      username: 'admin',
      secret: 'token',
      monitoring_jobs: ['A']
    }

    assert_response 403
  end

  def test_update_update
    WebMock.enable!

    project = Project.find(5)
    project.enable_module!(:jenkins_job)

    stub_request(:head, 'http://127.0.0.1:8080/api/json')

    put :update, params: {
      project_id: project.id,
      enable: true,
      url: 'http://127.0.0.1:8080/',
      link_url: 'http://jenkins:8080/',
      skip_ssl_verify: true,
      username: 'user',
      secret: 'password',
      monitoring_jobs: ['A']
    }

    assert_redirected_to "/projects/#{project.identifier}/settings/jenkins_job"
    assert_not_nil flash[:notice]
    assert_nil flash[:error]

    project.reload
    assert_equal 'http://127.0.0.1:8080/', project.jenkins_setting.url
    assert_equal 'http://jenkins:8080/', project.jenkins_setting.link_url
    assert_equal true, project.jenkins_setting.skip_ssl_verify
    assert_equal 'user', project.jenkins_setting.username
    assert_equal 'password', project.jenkins_setting.secret
    assert_equal 1, project.jenkins_setting.monitoring_jobs.length
    assert_includes project.jenkins_setting.monitoring_jobs, 'A'
  ensure
    WebMock.disable!
  end

  def test_update_destroy
    project = Project.find(5)
    project.enable_module!(:jenkins_job)

    put :update, params: {
      project_id: project.id,
      enable: false
    }

    assert_redirected_to "/projects/#{project.identifier}/settings/jenkins_job"
    assert_not_nil flash[:notice]
    assert_nil flash[:error]

    project.reload
    assert_nil project.jenkins_setting
  end
end
