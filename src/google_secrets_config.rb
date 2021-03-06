require 'logger'
require_relative './logger'

module MyLogger
  LOGGER = Logger.new $stderr, level: Logger::WARN
  def logger
    LOGGER
  end
end

# Define a gRPC module-level logger method before grpc/logconfig.rb loads.
module GRPC
  extend MyLogger
end

require 'google/cloud/secret_manager'

module SecretStrava
  class GoogleSecretsConfig
    include SecretStrava::Log
    def init
      @client ||= Google::Cloud::SecretManager.secret_manager_service
      @name = 'secret-strava'
    end
    def method_missing(m)
      self.init
      secret_name = m.to_s.upcase
      secret_key =
        @client.secret_version_path project: @name,
                                    secret: secret_name,
                                    secret_version: 'latest'
      log.debug "testing #{secret_name} to #{secret_key}"
      begin
        res = @client.access_secret_version name: secret_key
      rescue Google::Cloud::NotFoundError
        return nil
      end
      res&.payload&.data
    end
  end
end
