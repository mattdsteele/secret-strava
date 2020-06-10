require 'yaml'
module SecretStrava
  class YamlConfig
    def initialize
      @config = YAML.load_file('config.yml')
    end

    def method_missing(m)
      args = m.to_s.split '_'
      @config.send :dig, *args
    end
  end
end
