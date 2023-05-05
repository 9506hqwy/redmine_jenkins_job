# frozen_string_literal: true

RedmineApp::Application.routes.draw do
  resources :projects do
    get '/jenkins_job/jobs', to: 'jenkins_job#index', format: false
    get '/jenkins_job/jobs/:job_path', to: 'jenkins_job#job', format: false
    get '/jenkins_job/jobs/:job_path/builds', to: 'jenkins_job#builds', format: false
    post '/jenkins_job/jobs/:job_path/builds', to: 'jenkins_job#exec', format: false
    get '/jenkins_job/jobs/:job_path/builds/:id', to: 'jenkins_job#build', format: false
    get '/jenkins_job/jobs/:job_path/builds/:id/artifacts', to: 'jenkins_job#artifacts', format: false
    get '/jenkins_job/jobs/:job_path/builds/:id/output', to: 'jenkins_job#output', format: false
    put '/jenkins_setting', to: 'jenkins_setting#update', format: false
    get '/jenkins_setting/:folder_path', to: 'jenkins_setting#jobs', format: false
  end
end
