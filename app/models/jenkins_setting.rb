# frozen_string_literal: true

class JenkinsSetting < ActiveRecord::Base
  include Redmine::Ciphering

  belongs_to :project

  validates :url, presence: true
  validates :username, presence: true
  validates :secret, presence: true

  def secret
    read_ciphered_attribute(:secret)
  end

  def secret=(arg)
    write_ciphered_attribute(:secret, arg)
  end

  def monitoring_jobs
    v = read_attribute(:monitoring_jobs)
    YAML.safe_load(v) if v
  end

  def monitoring_jobs=(v)
    write_attribute(:monitoring_jobs, v.to_yaml.to_s)
  end

  delegate :job, to: :client

  def jobs
    return if url.blank?

    @root = client.root if @root.blank?

    @root
  end

  def version
    return if url.blank?

    @version = client.version if @version.blank?

    @version
  end

  def client
    return @client if @clinet.present?

    @client = RedmineJenkinsJob::JenkinsClient.new(
      url,
      username,
      secret,
      skip_ssl_verify,
      link_url)

    @client
  end
end
