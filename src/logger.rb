require 'logger'

module SecretStrava
  module Log
    def log
      Log.logger
    end
    def self.logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end