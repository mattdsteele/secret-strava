require_relative '../src/user_repo'
require_relative '../src/strava_client'

r = SecretStrava::UserRepo.new
c = SecretStrava::StravaClient.new

user_data = r.get_or_refresh 1_751_710
client = c.client_for user_data.access_token
latest_activity = client.athlete_activities.first
puts "#{latest_activity.name}: #{latest_activity.type_emoji}"
