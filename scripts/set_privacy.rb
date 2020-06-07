require_relative '../src/privacy_client.rb'
require 'dotenv/load'

user = ENV['STRAVA_USER']
password = ENV['STRAVA_PASSWORD']
client = SecretStrava::PrivacyClient.new({user: user, password: password})
client.auth
client.make_followers_only 3574257256