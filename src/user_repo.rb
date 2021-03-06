require 'graphql/client'
require 'graphql/client/http'
require 'date'
require_relative './logger'
require_relative './strava_client'
require_relative './config'

module SecretStrava # Configure GraphQL endpoint using the basic HTTP network adapter.
  HTTP =
    GraphQL::Client::HTTP.new('https://graphql.fauna.com/graphql') do
      def headers(context)
        config = SecretStrava::Config.new # Optionally set any HTTP headers
        { "Authorization": "Bearer #{config.fauna_key}" }
      end
    end

  # Fetch latest schema on init, this will make a network request
  Schema = GraphQL::Client.load_schema(HTTP)

  # However, it's smart to dump this to a JSON file and load from disk
  #
  # Run it from a script or rake task
  #   GraphQL::Client.dump_schema(SWAPI::HTTP, "path/to/schema.json")
  #
  # Schema = GraphQL::Client.load_schema("path/to/schema.json")

  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

  CreateUserQuery =
    Client.parse <<-'GRAPHQL'
  mutation ($athlete:UserInput!) {
    createUser(data: $athlete) {
      _id
    }
  }
  GRAPHQL

  GetUserQuery =
    Client.parse <<-'GRAPHQL'
    query($athleteId: Int!) {
      userById(athleteId: $athleteId) {
        _id
        athleteId
        accessToken
        refreshToken
        expiresAt
      }
    }
  GRAPHQL

  UpdateUserTokenQuery =
    Client.parse <<-'GRAPHQL'
  mutation($athleteId: ID!, $athlete: UserInput!) {
    updateUser(id: $athleteId, data: $athlete) {
      _id
      athleteId
      accessToken
      refreshToken
      expiresAt
    }

  }
  GRAPHQL

  class LegacyUser
    attr_accessor :athlete_id, :expires_at, :refresh_token, :access_token
    def initialize(athlete_hash)
      @athlete = athlete_hash
      @athlete_id = athlete_hash[:athleteId]
      @expires_at = athlete_hash[:expiresAt]
      @refresh_token = athlete_hash[:refreshToken]
      @access_token = athlete_hash[:accessToken]
    end
  end
  class FirestoreUserRepo
    include SecretStrava::Log

    def initialize
      require "google/cloud/firestore"
      project_id = 'secret-strava'
      @firestore = Google::Cloud::Firestore.new project_id: project_id
    end

    def create(auth_data)
    end
    def get(athlete_id)
      doc = get_ref athlete_id
      get_as_legacy doc
    end
    def get_ref(athlete_id)
      users_ref = @firestore.col 'users'
      query = users_ref.where('athleteId', '==', athlete_id).limit(1)
      query.get do |q|
        return q
      end
      raise "did not find athlete data"
    end
    def get_as_legacy(athlete_ref)
      LegacyUser.new athlete_ref.data
    end
    def get_or_refresh(athlete_id)
      current_data = get athlete_id
      puts current_data
      expiry = DateTime.iso8601 current_data.expires_at
      past_expiry = (expiry <=> DateTime.now) == -1
      return current_data unless past_expiry
      log.debug "refreshing expired access token for #{athlete_id}"
      strava = SecretStrava::StravaClient.new
      refresh_data = strava.refresh current_data.refresh_token
      log.debug 'got refresh data, persisting'
      log.debug refresh_data
      update(current_data, refresh_data)
      refresh_data
    end
    def update(current_data, refresh_data)
    end

  end
  class UserRepo
    include SecretStrava::Log

    def initialize
      @client = Client
    end

    def c
      @client
    end

    def create(auth_data)
      result = @client.query(CreateUserQuery, variables: { athlete: auth_data })
      result
    end
    def get(athlete_id)
      result = @client.query(GetUserQuery, variables: { athleteId: athlete_id })
      result.data.user_by_id
    end
    def get_or_refresh(athlete_id)
      current_data = get athlete_id
      expiry = DateTime.iso8601 current_data.expires_at
      past_expiry = (expiry <=> DateTime.now) == -1
      return current_data unless past_expiry
      log.debug "refreshing expired access token for #{athlete_id}"
      strava = SecretStrava::StravaClient.new
      refresh_data = strava.refresh current_data.refresh_token
      log.debug 'got refresh data, persisting'
      log.debug refresh_data
      update(current_data, refresh_data)
      refresh_data
    end
    def update(current_data, refresh_data)
      expires_at =
        refresh_data.expires_at.to_datetime.new_offset(0).iso8601.sub! '+00:00',
                                                                       'Z'
      res =
        @client.query(
          UpdateUserTokenQuery,
          variables: {
            athleteId: current_data._id,
            athlete: {
              athleteId: current_data.athlete_id,
              refreshToken: refresh_data.refresh_token,
              expiresAt: expires_at,
              accessToken: refresh_data.access_token
            }
          }
        )
      log.debug('saved new data')
      pp res
      res.data.update_user
    end
  end
end
