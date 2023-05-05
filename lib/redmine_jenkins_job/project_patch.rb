# frozen_string_literal: true

module RedmineJenkinsJob
  module ProjectPatch
    def self.prepended(base)
      base.class_eval do
        has_one :jenkins_setting, dependent: :destroy
      end
    end
  end
end

Project.prepend RedmineJenkinsJob::ProjectPatch
