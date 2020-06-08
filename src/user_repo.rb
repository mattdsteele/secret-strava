require 'graphql/client'
require 'graphql/client/http'
require_relative './logger'

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
      puts 'made it here'
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
      result
    end
  end
end
