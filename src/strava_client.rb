require_relative './logger'
require_relative './config'
require 'strava-ruby-client'

module SecretStrava
  class StravaClient
    include SecretStrava::Log

    def initialize
      log.debug 'initializing client'
      c = SecretStrava::Config.parse
      auth = c['auth']
      @@host = "https://#{auth['host']}"
      @@oauth_path = auth['oauth-path']

      @client =
        Strava::OAuth::Client.new(
          client_id: ENV['STRAVA_CLIENT_ID'],
          client_secret: ENV['STRAVA_CLIENT_SECRET']
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
  end
end
