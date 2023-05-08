# frozen_string_literal: true

require 'webmock'
require File.expand_path('../../test_helper', __FILE__)

class JenkinsJobControllerTest < Redmine::ControllerTest
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

    @project = Project.find(5)
    @project.enable_module!(:jenkins_job)

    role = Role.find(1)
    role.add_permission!(:view_jenkins_job)
    role.add_permission!(:edit_jenkins_job)
  end

  def test_index
    WebMock.enable!

    @project.jenkins_setting.monitoring_jobs = ['job/test/']
    @project.jenkins_setting.save!

    query = RedmineJenkinsJob::Utils.job_query
    stub_request(:get, "https://127.0.0.1:8080/job/test/api/json?#{query}").
      to_return(body: '{"fileName": "test", "name": "name", "url": "https://jenkins:8080/job/test/" }')

    get :index, params: {
      project_id: @project.id
    }

    assert_response :success
    assert_select 'tr#job-e3373e24e884a5b5c7e3ca51645847cf'
  ensure
    WebMock.disable!
  end

  def test_index_x2
    WebMock.enable!

    @project.jenkins_setting.monitoring_jobs = ['job/test2/', 'job/test1/']
    @project.jenkins_setting.save!

    query = RedmineJenkinsJob::Utils.job_query
    stub_request(:get, "https://127.0.0.1:8080/job/test1/api/json?#{query}").
      to_return(body: '{"fileName": "test1", "name": "name", "url": "https://jenkins:8080/job/test1/" }')
    stub_request(:get, "https://127.0.0.1:8080/job/test2/api/json?#{query}").
      to_return(body: '{"fileName": "test2", "name": "name", "url": "https://jenkins:8080/job/test2/" }')

    get :index, params: {
      project_id: @project.id
    }

    assert_response :success
    assert_select 'tr#job-b596ea1306ee69268ac23a953d280598', 1
    assert_select 'tr#job-bb0091c7c943b844b575977e2c45f390', 1
  ensure
    WebMock.disable!
  end

  def test_index_not_found
    WebMock.enable!

    @project.jenkins_setting.monitoring_jobs = ['job/test/']
    @project.jenkins_setting.save!

    query = RedmineJenkinsJob::Utils.job_query
    stub_request(:get, "https://127.0.0.1:8080/job/test/api/json?#{query}").
      to_return(status: 404)

    get :index, params: {
      project_id: @project.id
    }

    assert_response :success

    @project.reload
    assert @project.jenkins_setting.monitoring_jobs.empty?
  ensure
    WebMock.disable!
  end

  def test_artifacts
    WebMock.enable!

    query = RedmineJenkinsJob::Utils.build_query
    stub_request(:get, "https://127.0.0.1:8080/job/test/1/api/json?#{query}").
      to_return(body: '{"artifacts": [{"fileName": "test.log", "relativePath": "test.log"}], "url": "https://jenkins:8080/job/test/1/"}')
    stub_request(:head, "https://127.0.0.1:8080/job/test/1/artifact/test.log").
      to_return(headers: {'Content-Length': '1'})

    get :artifacts, params: {
      project_id: @project.id,
      job_path: 'job/test/',
      id: '1'
    }

    assert_response :success
    assert_select 'a[href="https://jenkins:8080/job/test/1/artifact/test.log"]'
  ensure
    WebMock.disable!
  end

  def test_build
    WebMock.enable!

    query = RedmineJenkinsJob::Utils.build_query
    stub_request(:get, "https://127.0.0.1:8080/job/test/1/api/json?#{query}").
      to_return(body: '{"artifacts": [{"fileName": "test.log", "relativePath": "test.log"}], "building": false, "displayName": "test", "id": "1", "result": "SUCCESS", "timestamp": 0, "url": "https://jenkins:8080/job/test/1/"}')

    get :build, params: {
      project_id: @project.id,
      job_path: 'job/test/',
      id: '1'
    }

    assert_response :success
    assert_select 'tr#job-e3373e24e884a5b5c7e3ca51645847cf-1'
  ensure
    WebMock.disable!
  end

  def test_builds
    WebMock.enable!

    jquery = RedmineJenkinsJob::Utils.job_query
    bquery = RedmineJenkinsJob::Utils.build_query
    stub_request(:get, "https://127.0.0.1:8080/job/test/api/json?#{jquery}").
      to_return(body: '{"builds": [{"url": "https://jenkins:8080/job/test/1/"}], "url": "https://jenkins:8080/job/test/"}')
    stub_request(:get, "https://127.0.0.1:8080/job/test/1/api/json?#{bquery}").
      to_return(body: '{"artifacts": [{"fileName": "test.log", "relativePath": "test.log"}], "building": false, "displayName": "test", "id": "1", "result": "SUCCESS", "timestamp": 0, "url": "https://jenkins:8080/job/test/1/"}')

    get :builds, params: {
      project_id: @project.id,
      job_path: 'job/test/'
    }

    assert_response :success
    assert_select 'tr#job-e3373e24e884a5b5c7e3ca51645847cf-1'
  ensure
    WebMock.disable!
  end

  def test_job
    WebMock.enable!

    query = RedmineJenkinsJob::Utils.job_query
    stub_request(:get, "https://127.0.0.1:8080/job/test/api/json?#{query}").
      to_return(body: '{"fileName": "test", "name": "name", "url": "https://jenkins:8080/job/test/" }')

    get :job, params: {
      project_id: @project.id,
      job_path: 'job/test/'
    }

    assert_response :success
    assert_select 'tr#job-e3373e24e884a5b5c7e3ca51645847cf'
  ensure
    WebMock.disable!
  end

  def test_exec
    WebMock.enable!

    jquery = RedmineJenkinsJob::Utils.job_query
    bquery = RedmineJenkinsJob::Utils.build_query
    stub_request(:get, "https://127.0.0.1:8080/job/test/api/json?#{jquery}").
      to_return(body: '{"url": "https://jenkins:8080/job/test/"}')
    stub_request(:get, "https://127.0.0.1:8080/crumbIssuer/api/json").
      to_return(body: '{"crumb": "value", "crumbRequestField": "key"}')
    stub_request(:post, "https://127.0.0.1:8080/job/test/build").
      to_return(headers: {Location: 'https://jenkins:8080/job/test/1/'})
    stub_request(:get, "https://127.0.0.1:8080/job/test/1/api/json?#{bquery}").
      to_return(body: '{"artifacts": [{"fileName": "test.log", "relativePath": "test.log"}], "building": false, "displayName": "test", "id": "1", "result": "SUCCESS", "timestamp": 0, "url": "https://jenkins:8080/job/test/1/"}')

    post :exec, params: {
      project_id: @project.id,
      job_path: 'job/test/'
    }

    assert_response :success
    assert_select 'tr#job-e3373e24e884a5b5c7e3ca51645847cf-1'
  ensure
    WebMock.disable!
  end

  def test_output
    WebMock.enable!

    query = RedmineJenkinsJob::Utils.build_query
    stub_request(:get, "https://127.0.0.1:8080/job/test/1/api/json?#{query}").
      to_return(body: '{"url": "https://jenkins:8080/job/test/1/"}')
    stub_request(:get, "https://127.0.0.1:8080/job/test/1/consoleText").
      to_return(body: 'test')

    get :output, params: {
      project_id: @project.id,
      job_path: 'job/test/',
      id: '1'
    }

    assert_response :success
  ensure
    WebMock.disable!
  end
end
