# frozen_string_literal: true

module RedmineJenkinsJob
  class JenkinsBuild
    def initialize(client, build, link_url)
      @client = client
      @build = build
      @link_url = link_url.presence || client.url
    end

    def artifacts
      (@build['artifacts'] || []).map do |artifact|
        JenkinsArtifact.new(@client, self, artifact, @link_url)
      end
    end

    def building
      @build['building']
    end

    def display_name
      @build['displayName']
    end

    def id
      @build['id']
    end

    def result
      @build['result']
    end

    def timestamp
      @build['timestamp']
    end

    def browse_url
      @build['url']
    end

    def datetime
      Time.at(timestamp / 1000) if timestamp.present?
    end

    def path
      Utils.rel_path(browse_url, @link_url) if browse_url.present?
    end

    def output
      @output = @client.build_output(path) if @output.blank?

      @output
    end
  end
end
