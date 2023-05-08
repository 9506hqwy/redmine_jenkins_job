# frozen_string_literal: true

require 'net/http'

class JenkinsJobController < ApplicationController
  before_action :find_project_by_project_id, :authorize
  before_action :find_job_path, only: [:builds, :job, :exec]
  before_action :find_build_path, only: [:artifacts, :build, :output]

  def index
    setting = @project.jenkins_setting || JenkinsSetting.new

    jobs = []
    not_found = []
    (setting.monitoring_jobs || []).each do |job_path|
      begin
        jobs.push(client.job(job_path))
      rescue Net::HTTPExceptions => e
        if e.response.code == '404'
          not_found.push(job_path)
        else
          return render_error(message: e.message)
        end
      rescue => e
        return render_error(message: e.message)
      end
    end

    if not_found.any?
      setting.monitoring_jobs = setting.monitoring_jobs.reject! { |j| not_found.include?(j) }
      setting.save
    end

    @jobs = jobs.sort_by {|j| j.full_name}
  end

  def artifacts
    build = client.build(@build_path)

    @artifacts = build.artifacts

    render(partial: 'jenkins_job/artifacts')
  end

  def build
    @builds = [client.build(@build_path)]

    render(partial: 'jenkins_job/builds')
  end

  def builds
    job = client.job(@job_path)

    @job_id = job.id

    @builds = job.builds

    render(partial: 'jenkins_job/builds')
  end

  def job
    job = client.job(@job_path)

    @jobs = [job]

    render(partial: 'jenkins_job/jobs')
  end

  def exec
    job = client.job(@job_path)

    @job_id = job.id

    build = job.exec

    @builds = [build]

    render(partial: 'jenkins_job/builds')
  end

  def output
    build = client.build(@build_path)

    output = build.output

    render(plain: build.output)
  end

  private

  def client
    @project.jenkins_setting.client if @project.jenkins_setting.present?
  end

  def find_job_path
    @job_path = params[:job_path]
    @job_id = RedmineJenkinsJob::Utils.job_id(@job_path)
  end

  def find_build_path
    find_job_path
    build_id = params[:id]
    @build_path = "#{@job_path}#{build_id}/"
  end
end
