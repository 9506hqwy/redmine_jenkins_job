# frozen_string_literal: true

class CreateJenkinsSettings < RedmineJenkinsJob::Utils::Migration
  def change
    create_table :jenkins_settings do |t|
      t.belongs_to :project, null: false, foreign_key: true
      t.string :url
      t.string :link_url
      t.boolean :skip_ssl_verify
      t.string :username
      t.string :secret
      t.string :monitoring_jobs
    end
  end
end
