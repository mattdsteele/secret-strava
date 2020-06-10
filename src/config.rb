require_relative './yaml_config'
module SecretStrava
  class Config
    def initialize
      @configs = [YamlConfig.new]
    end
    def method_missing(m)
      @configs.each do |c|
        res = c.send m
        return res if res != nil
      end
    end
  end
end
