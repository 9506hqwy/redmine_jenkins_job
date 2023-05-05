# frozen_string_literal: true

module RedmineJenkinsJob
  class JenkinsJobDetail
    def initialize(client, job, link_url)
      @client = client
      @job = job
      @link_url = link_url.presence || client.url
    end

    def full_name
      @job['fullName']
    end

    def name
      @job['name']
    end

    def browse_url
      @job['url']
    end

    def path
      Utils.rel_path(browse_url, @link_url)
    end

    def id
      Utils.job_id(self)
    end

    def last_build_id
      @job['lastBuild']['number'] if @job['lastBuild'].present?
    end

    def last_build_artifacts
      last_build.artifacts if last_build.present?
    end

    def last_build_result
      last_build.result if last_build.present?
    end

    def last_build_timestamp
      last_build.timestamp if last_build.present?
    end

    def last_build_datetime
      Time.at(last_build_timestamp / 1000) if last_build_timestamp.present?
    end

    def last_build_path
      Utils.rel_path(last_build_browse_url, @link_url) if last_build_browse_url.present?
    end

    def builds
      if @builds.blank?
        @builds = @job['builds'].map do |build|
          build_path = Utils.rel_path(build['url'], @link_url)
          @client.build(build_path)
        end
      end

      @builds
    end

    def jobs
      @job['jobs'].map do |child|
        JenkinsJob.new(@client, child, @link_url)
      end
    end

    def exec
      @client.exec(path)
    end

    private

    def last_build
      return if last_build_path.blank?

      @last_build = @client.build(last_build_path) if @last_build.blank?

      @last_build
    end

    def last_build_browse_url
      @job['lastBuild']['url'] if @job['lastBuild'].present?
    end
  end
end
