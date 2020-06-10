require_relative './yaml_config'
require_relative './env_config'
require_relative './google_secrets_config'
require_relative './logger'
module SecretStrava
  class Config
    include SecretStrava::Log
    def initialize
      @configs = [YamlConfig.new, EnvConfig.new, GoogleSecretsConfig.new]
    end
    def method_missing(m)
      logger.debug "getting config for #{m.to_s}"
      @configs.each do |c|
        res = c.send m
        logger.debug "found value: #{res}" if res != nil
        return res if res != nil
      end
      nil
    end
  end
end
