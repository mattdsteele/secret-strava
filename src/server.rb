require 'dotenv/load'
require 'sinatra'
require 'liquid'
require_relative './strava_client'
require_relative './user_repo'
require_relative './ride_classifier'
require_relative './privacy_client'
require 'date'

client = SecretStrava::StravaClient.new
user = SecretStrava::FirestoreUserRepo.new
classifier = SecretStrava::RideClassifier.new
privacy = SecretStrava::PrivacyClient.new

get '/' do
  u = client.auth_url
  liquid :index, locals: { foo: u }
end

get '/auth-response' do
  event = client.auth_token(params[:code])
  puts event
  puts event.expires_at.class
  expires_at =
    event.expires_at.to_datetime.new_offset(0).iso8601.sub! '+00:00', 'Z'
  athlete = {
    athleteId: event.athlete.id,
    accessToken: event.access_token,
    refreshToken: event.refresh_token,
    expiresAt: expires_at
  }
  res = user.create athlete
  puts 'created athlete in repo'
  pp res
  redirect '/auth-success'
end

get '/auth-success' do
  liquid :authed
end

get '/events' do
  challenge = params['hub.challenge']
  mode = params['hub.mode']
  token = params['hub.verify_token']
  content_type :json
  "Data: #{challenge} #{mode} #{token}"
  { 'hub.challenge' => challenge }.to_json
end

post '/events' do
  body = request.body.read
  event = Strava::Webhooks::Models::Event.new(JSON.parse(body))
  pp event
  user_data = user.get_or_refresh event.owner_id
  user_client = client.client_for user_data.access_token
  activity = user_client.activity event.object_id

  puts "#{activity.name}: #{activity.type_emoji}"

  res = classifier.classify activity
  if res == nil
    puts "not acting on #{activity.name}"
  elsif res != activity.visibility
    puts "updating visibility of event: #{activity.id} from #{
            activity.visibility
          } to #{res}"
    privacy.auth
    puts "successfully authenticated"
    mappings = {
      'private': :make_private,
      'followers_only': :make_followers_only,
      'everyone': :make_public
    }
    privacy.send mappings[res.to_sym], activity.id
    puts 'done'
  else
    puts "visibility for activity #{activity.id} already good at #{res}"
  end

  content_type :json
  { ok: true }.to_json
end
