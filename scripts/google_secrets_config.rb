require 'dotenv/load'
require_relative '../src/google_secrets_config'

c = SecretStrava::GoogleSecretsConfig.new

puts c.test_secret
