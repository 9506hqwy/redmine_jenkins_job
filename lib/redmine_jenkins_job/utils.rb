# frozen_string_literal: true

require 'digest/md5'

module RedmineJenkinsJob
  module Utils
    if ActiveRecord::VERSION::MAJOR >= 5
      Migration = ActiveRecord::Migration[4.2]
    else
      Migration = ActiveRecord::Migration
    end

    if defined?(ApplicationRecord)
      # https://www.redmine.org/issues/38975
      ModelBase = ApplicationRecord
    else
      ModelBase = ActiveRecord::Base
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

    # https://guides.rubyonrails.org/routing.html#dynamic-segments
    # By default, dynamic segments don't accept dots
    #
    # Can allow "." in path parameter using regular expression in `constraints`.
    # But allow "/" in path parameter using regular expression in `constraints` at the same time,
    # Unexpected value is matched to allowed non-tailing path parameter.
    # So does not use `constraints`.
    #
    # Use URL path after replace "." to "|",
    # Because Jenkins job name does not permit contain "|".
    def self.decode_job_path(path)
      path.tr('|', '.')
    end

    def self.encode_job_path(path)
      path.tr('.', '|')
    end
  end
end
