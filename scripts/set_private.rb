require_relative '../src/privacy_client.rb'
require 'dotenv/load'

user = ENV['STRAVA_USER']
password = ENV['STRAVA_PASSWORD']
client = PrivacyClient.new({user: user, password: password})
client.auth
client.make_public 3574257256