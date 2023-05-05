# frozen_string_literal: true

require 'net/http'
require 'json'

module RedmineJenkinsJob
  class JenkinsClient
    def initialize(url, username, secret, skip_ssl_verify, link_url)
      @url = url
      @username = username
      @secret = secret
      @skip_ssl_verify = skip_ssl_verify
      @link_url = link_url
    end

    attr_reader :url

    def content_length(path)
      request = Net::HTTP::Head.new(abs_path(path))
      response = send(request)
      response['Content-Length']
    end

    def crumb
      request = Net::HTTP::Get.new(abs_path("crumbIssuer/api/json"))
      response = send(request)
      json = JSON.parse(response.body)
      { json['crumbRequestField'] => json['crumb'] }
    end

    def build(path)
      query = Utils.build_query
      request = Net::HTTP::Get.new(abs_path("#{path}api/json") + "?#{query}")
      response = send(request)
      json = JSON.parse(response.body)
      JenkinsBuild.new(self, json, @link_url)
    end

    def build_output(path)
      request = Net::HTTP::Get.new(abs_path("#{path}consoleText"))
      response = send(request)
      response.body
    end

    def exec(path)
      request = Net::HTTP::Post.new(abs_path("#{path}build"))
      crumb.each do |(k, v)|
        request[k] = v
      end
      response = send(request)
      build_url = response['Location']
      build_path = Utils.rel_path(build_url, @link_url)
      build(build_path)
    end

    def job(path)
      query = Utils.job_query
      request = Net::HTTP::Get.new(abs_path("#{path}api/json") + "?#{query}")
      response = send(request)
      json = JSON.parse(response.body)
      JenkinsJobDetail.new(self, json, @link_url)
    end

    def root
      query = Utils.root_query
      request = Net::HTTP::Get.new(abs_path('api/json') + "?#{query}")
      response = send(request)
      json = JSON.parse(response.body)
      json['jobs'].map do |job|
        JenkinsJob.new(self, job, @link_url)
      end
    end

    def version
      request = Net::HTTP::Head.new(abs_path('api/json'))
      response = send(request)
      response['X-Jenkins']
    end

    private

    def abs_path(rel_path)
      base_uri = URI.parse(@url).path.chomp('/')

      if rel_path.start_with?('/')
        rel_path = rel_path.slice(1..-1)
      end

      "#{base_uri}/#{rel_path.chomp('/')}"
    end

    def send(request)
      uri = URI.parse(@url)

      request.basic_auth(@username, @secret)

      conn = Net::HTTP.new(uri.host, uri.port)
      conn.use_ssl = uri.scheme == 'https'
      if @skip_ssl_verify
        conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
      else
        conn.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end

      response = conn.start do |http|
        http.request(request)
      end

      response.value # raise if not 2xx

      response
    end
  end
end
