require 'graphql/client'
require 'graphql/client/http'
require 'date'
require_relative './logger'
require_relative './strava_client'

module SecretStrava # Configure GraphQL endpoint using the basic HTTP network adapter.
  HTTP =
    GraphQL::Client::HTTP.new('https://graphql.fauna.com/graphql') do
      def headers(context)
        # Optionally set any HTTP headers
        { "Authorization": "Bearer #{ENV['FAUNA_KEY']}" }
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
