require 'yaml'
module SecretStrava
  class YamlConfig
    def initialize
      @config = YAML.load_file('config.yml')
    end

    def method_missing(m, *args)
      args = m.to_s.split '_'
      config_state = @config
      while args.length > 0 && config_state != nil
        next_val = args.shift
        config_state = config_state[next_val]
      end
      config_state
    end
  end
end
