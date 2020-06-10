require 'dotenv/load'

module SecretStrava
  class EnvConfig
    def method_missing(m)
      ENV[m.to_s.upcase]
    end
  end
end
