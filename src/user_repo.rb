require 'date'
require_relative './logger'
require_relative './strava_client'
require_relative './config'

module SecretStrava
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
end
