# frozen_string_literal: true

require 'webmock'
require File.expand_path('../../test_helper', __FILE__)

class JenkinsClientTest < ActiveSupport::TestCase
  include WebMock::API

  fixtures :projects,
           :jenkins_settings

  def setup
    @setting = jenkins_settings(:jenkins_settings_001)
    @client = @setting.client
  end

  def test_content_length
      WebMock.enable!

      stub_request(:head, 'https://127.0.0.1:8080/test').
          to_return(headers: { 'Content-Length': '1'})

      size = @client.content_length('test/')

      assert_equal '1', size
  ensure
    WebMock.disable!
  end

  def test_build
      WebMock.enable!

      query = RedmineJenkinsJob::Utils.build_query
      stub_request(:get, "https://127.0.0.1:8080/test/api/json?#{query}").
          to_return(body: '{}')

      build = @client.build('test/')

      assert build.instance_of?(RedmineJenkinsJob::JenkinsBuild)
  ensure
    WebMock.disable!
  end

  def test_build_output
      WebMock.enable!

      stub_request(:get, "https://127.0.0.1:8080/test/consoleText").
          to_return(body: 'text')

      stdout = @client.build_output('test/')

      assert_equal 'text', stdout
  ensure
    WebMock.disable!
  end

  def test_exec
      WebMock.enable!

      stub_request(:get, "https://127.0.0.1:8080/crumbIssuer/api/json").
          to_return(body: '{"crumb": "value", "crumbRequestField": "key"}')
      stub_request(:post, "https://127.0.0.1:8080/test/build").
          to_return(headers: {Location: 'https://127.0.0.1:8080/test/1/'})

      query = RedmineJenkinsJob::Utils.build_query
      stub_request(:get, "https://127.0.0.1:8080/test/1/api/json?#{query}").
          to_return(body: '{}')

      build = @client.exec('test/')

      assert build.instance_of?(RedmineJenkinsJob::JenkinsBuild)
  ensure
    WebMock.disable!
  end

  def test_job
      WebMock.enable!

      query = RedmineJenkinsJob::Utils.job_query
      stub_request(:get, "https://127.0.0.1:8080/test/api/json?#{query}").
          to_return(body: '{}')

      job = @client.job('test/')

      assert job.instance_of?(RedmineJenkinsJob::JenkinsJobDetail)
  ensure
    WebMock.disable!
  end

  def test_root
      WebMock.enable!

      query = RedmineJenkinsJob::Utils.root_query
      stub_request(:get, "https://127.0.0.1:8080/api/json?#{query}").
          to_return(body: '{"jobs": [{}]}')

      jobs = @client.root

      assert_equal 1, jobs.length
      assert jobs[0].instance_of?(RedmineJenkinsJob::JenkinsJob)
  ensure
    WebMock.disable!
  end

  def test_version
      WebMock.enable!

      stub_request(:head, "https://127.0.0.1:8080/api/json").
          to_return(headers: {'X-Jenkins': '1'})

      version = @client.version

      assert_equal '1', version
  ensure
    WebMock.disable!
  end
end
