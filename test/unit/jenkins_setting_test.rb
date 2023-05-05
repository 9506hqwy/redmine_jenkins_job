# frozen_string_literal: true

require 'webmock'
require File.expand_path('../../test_helper', __FILE__)

class JenkinsSettingTest < ActiveSupport::TestCase
  include WebMock::API

  fixtures :projects,
           :jenkins_settings

  def test_create
    p = projects(:projects_001)

    s = JenkinsSetting.new
    s.project = p
    s.url = 'https://127.0.0.1:8080/'
    s.link_url = 'https://jenkins:8080/'
    s.skip_ssl_verify = true
    s.username = 'admin'
    s.secret = 'token'
    s.monitoring_jobs = ['A', 'B']
    s.save!

    s.reload
    assert_equal p.id, s.project_id
    assert_equal 'https://127.0.0.1:8080/', s.url
    assert_equal 'https://jenkins:8080/', s.link_url
    assert_equal true, s.skip_ssl_verify
    assert_equal 'admin', s.username
    assert_equal 'token', s.secret
    assert_equal 2, s.monitoring_jobs.length
    assert_includes s.monitoring_jobs, 'A'
    assert_includes s.monitoring_jobs, 'B'
  end

  def test_update
    p = projects(:projects_005)

    s = p.jenkins_setting
    s.url = 'http://127.0.0.1:8080/'
    s.link_url = 'http://jenkins:8080/'
    s.skip_ssl_verify = false
    s.username = 'user'
    s.secret = 'password'
    s.monitoring_jobs = ['A', 'B']
    s.save!

    s.reload
    assert_equal p.id, s.project_id
    assert_equal 'http://127.0.0.1:8080/', s.url
    assert_equal 'http://jenkins:8080/', s.link_url
    assert_equal false, s.skip_ssl_verify
    assert_equal 'user', s.username
    assert_equal 'password', s.secret
    assert_equal 2, s.monitoring_jobs.length
    assert_includes s.monitoring_jobs, 'A'
    assert_includes s.monitoring_jobs, 'B'
  end

  def test_version_nil
    s = JenkinsSetting.new

    v = s.version

    assert_nil v
  end

  def test_version_true
    WebMock.enable!

    stub_request(:head, 'https://127.0.0.1:8080/api/json')

    s = JenkinsSetting.new
    s.url = 'https://127.0.0.1:8080/'

    v = s.version

    assert_nil v
  ensure
    WebMock.disable!
  end
end
