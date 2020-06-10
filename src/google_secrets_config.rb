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
    def initialize
      @client = Google::Cloud::SecretManager.secret_manager_service
      @name = 'secret-strava'
    end
    def c
      @client
    end
    def method_missing(m)
      secret_name = m.to_s.upcase
      secret_key =
        @client.secret_version_path project: @name,
                                    secret: secret_name,
                                    secret_version: 'latest'
      logger.debug "testing #{secret_name} to #{secret_key}"
      begin
        res = @client.access_secret_version name: secret_key
      rescue Google::Cloud::NotFoundError
        return nil
      end
      res&.payload&.data
    end
  end
end
