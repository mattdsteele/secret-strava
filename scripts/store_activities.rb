require_relative '../src/user_repo'
require_relative '../src/strava_client'

r = SecretStrava::FirestoreUserRepo.new
c = SecretStrava::StravaClient.new

user_data = r.get_or_refresh 1_751_710
client = c.client_for user_data.access_token
def write_activity(id, name, client)
  activity = client.activity id
  data = Marshal.dump activity
  IO.write "spec/fixtures/activities/#{name}", data
end

write_activity 938516947, 'custom-title', client
# write_activity 3_441_346_632, 'commute', client
# write_activity 3_500_932_506, 'medium-ride', client
# write_activity 3_436_547_617, 'big-ride', client
# write_activity 938_516_947, 'indoor-short', client
# write_activity 60_041_372, 'shortride', client
