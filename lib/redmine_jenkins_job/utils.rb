# frozen_string_literal: true

require 'digest/md5'

module RedmineJenkinsJob
  module Utils
    if ActiveRecord::VERSION::MAJOR >= 5
      Migration = ActiveRecord::Migration[4.2]
    else
      Migration = ActiveRecord::Migration
    end

    def self.build_query
      'tree=artifacts[fileName,relativePath],building,displayName,id,result,timestamp,url'
    end

    def self.job_query
      'tree=fullName,name,url,lastBuild[number,url],jobs[_class,name,url],builds[url]{,20}'
    end

    def self.root_query
      'tree=jobs[_class,name,url]'
    end

    def self.rel_path(target, base)
      base = base.chomp('/')
      base = "#{base}/"

      path_uri = URI.parse(target) - URI.parse(base)
      path = path_uri.path.start_with?('/') ? path_uri.path.slice(1..-1) : path_uri.path

      "#{path.chomp('/')}/"
    end

    def self.job_id(job)
      case job
      when String
        digest = Digest::MD5.new
        digest.update(job)
        "job-#{digest.hexdigest}"
      else job_id(job.path)
      end
    end
  end
end
