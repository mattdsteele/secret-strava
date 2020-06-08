require 'dotenv/load'
require 'sinatra'
require 'liquid'
require_relative './strava_client'

c = SecretStrava::StravaClient.new
get '/' do
  u = c.auth_url(host: 'http://localhost:4567')
  liquid :index, locals: { foo: u }
end

get '/auth-response' do
  auth_token = c.auth_token(params[:code])
  liquid :authed, locals: { token: auth_token }
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
  content_type :json
  { ok: true }.to_json
end
