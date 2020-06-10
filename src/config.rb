require_relative './yaml_config'
require_relative './env_config'
require_relative './google_secrets_config'
module SecretStrava
  class Config
    def initialize
      @configs = [YamlConfig.new, EnvConfig.new, GoogleSecretsConfig.new]
    end
    def method_missing(m)
      @configs.each do |c|
        res = c.send m
        return res if res != nil
      end
      nil
    end
  end
end
