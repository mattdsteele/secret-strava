require 'yaml'
module SecretStrava
  class Config
    def self.parse
      YAML.load_file('config.yml')
    end
  end
end
