# frozen_string_literal: true

module RedmineJenkinsJob
  class JenkinsJob
    CONTAINER_CLASSES = [
      'com.cloudbees.hudson.plugins.folder.Folder',
      'jenkins.branch.OrganizationFolder',
      'org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject',
    ]

    def initialize(client, job, link_url)
      @client = client
      @job = job
      @link_url = link_url.presence || client.url
    end

    def folder?
      CONTAINER_CLASSES.include?(@job['_class'])
    end

    def name
      @job['name']
    end

    def browse_url
      @job['url']
    end

    def path
      Utils.rel_path(browse_url, @link_url) if browse_url.present?
    end

    def path_for_url
      Utils.encode_job_path(path)
    end

    def id
      Utils.job_id(self) if path.present?
    end
  end
end
