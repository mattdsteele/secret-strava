require 'dotenv/load'
require_relative '../src/google_secrets_config'

c = SecretStrava::GoogleSecretsConfig.new

puts c.fauna_key
puts c.foobar
