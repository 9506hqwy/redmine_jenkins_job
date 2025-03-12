# frozen_string_literal: true

class JenkinsSettingController < ApplicationController
  before_action :find_project_by_project_id, :authorize

  def jobs
    setting = @project.jenkins_setting

    folder = setting.job(RedmineJenkinsJob::Utils.decode_job_path(params[:folder_path]))

    @folder_id = folder.id

    @jobs = folder.jobs
    @monitoring_jobs = @project.jenkins_setting.monitoring_jobs || []

    render(partial: 'jenkins_setting/jobs')
  end

  def update
    setting = @project.jenkins_setting || JenkinsSetting.new

    begin
      if params[:enable].present? && params[:enable] != 'false'
        setting.project = @project
        setting.url = params[:url]
        setting.link_url = params[:link_url]
        setting.skip_ssl_verify = params[:skip_ssl_verify].present? && params[:skip_ssl_verify] != 'false'
        setting.username = params[:username]
        setting.secret = params[:password] if params[:password].present?
        setting.monitoring_jobs = (params[:monitoring_jobs] || []).reject {|m| m.blank? }

        setting.version # test connectivity
        setting.save!

        flash[:notice] = l(:notice_successful_update)
      elsif setting.url.present?
        @project.jenkins_setting.destroy!

        flash[:notice] = l(:notice_successful_update)
      end
    rescue => e
      Rails.logger.error(e)
      flash[:error] = e.message
    end

    redirect_to settings_project_path(@project, tab: :jenkins_job)
  end
end
