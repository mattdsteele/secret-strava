require 'dotenv/load'
require_relative '../src/strava_client'

puts 'doing a thing'
c = SecretStrava::StravaClient.new
pp c.auth_url(host: 'http://localhost:4243')
