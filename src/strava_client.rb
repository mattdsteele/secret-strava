require_relative './logger'
require_relative './config'
require 'strava-ruby-client'

module SecretStrava
  class StravaClient
    include SecretStrava::Log

    def initialize
      log.debug 'initializing client'
      c = SecretStrava::Config.new
      @@host = "https://#{c.auth_host}"
      @@oauth_path = c.auth_oauthpath

      @client =
        Strava::OAuth::Client.new(
          client_id: c.strava_client_id
          client_secret: c.strava_client_secret
        )
    end
    def auth_url(options = {})
      host_uri = options[:host] || @@host
      uri = "#{host_uri}#{@@oauth_path}"
      log.debug "generating auth against #{uri}"
      @client.authorize_url(
        redirect_uri: uri, scope: 'activity:read_all,activity:write'
      )
    end
    def auth_token(code)
      log.debug("getting auth token: #{code}")
      @client.oauth_token(code: code)
    end
    def refresh(refresh_token)
      @client.oauth_token(
        refresh_token: refresh_token, grant_type: 'refresh_token'
      )
    end
    def client_for(access_token)
      client = Strava::Api::Client.new(access_token: access_token)
      client
    end
  end
end
