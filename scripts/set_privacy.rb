require_relative '../src/privacy_client'
require_relative '../src/config'
c = SecretStrava::Config.new

user = c.strava_user
password = c.strava_password
client = SecretStrava::PrivacyClient.new({ user: user, password: password })
client.auth
client.make_followers_only 3_574_257_256
