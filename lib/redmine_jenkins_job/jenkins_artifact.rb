# frozen_string_literal: true

module RedmineJenkinsJob
  class JenkinsArtifact
    def initialize(client, build, artifact, link_url)
      @client = client
      @build = build
      @artifact = artifact
      @link_url = link_url.presence || client.url
    end

    def file_name
      @artifact['fileName']
    end

    def relative_path
      @artifact['relativePath']
    end

    def browse_url
      "#{@build.browse_url}artifact/#{relative_path}"
    end

    def size
      rel_path = "#{@build.path}artifact/#{relative_path}"
      @size = @client.content_length(rel_path) if @size.blank?
      @size
    end
  end
end
