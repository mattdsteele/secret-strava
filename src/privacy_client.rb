require 'mechanize'
require_relative './logger'

module SecretStrava
  class PrivacyClient
    include SecretStrava::Log

    def initialize(config = SecretStrava::EnvConfig.new)
      @user = config.strava_user
      @pass = config.strava_password
    end
    def auth
      log.debug "logging in with #{@user}/#{pass}"
      agent = Mechanize.new
      page = agent.get('https://strava.com/login')
      f = page.forms.first
      f.email = @user
      f.password = @pass
      page2 = agent.submit(f)
      @agent = agent
      log.debug 'Logged in'
      log.debug page2.inspect
      log.debug 'This was the page'
    end

    def make_private(activity_id)
      set_visibility activity_id, 'only_me'
    end
    def make_followers_only(activity_id)
      set_visibility activity_id, 'followers_only'
    end
    def make_public(activity_id)
      set_visibility activity_id, 'everyone'
    end

    private

    def set_visibility(activity_id, visibility)
      log.info "Setting #{activity_id} to #{visibility}"
      url = "https://www.strava.com/activities/#{activity_id}/edit"
      page = @agent.get(url)
      puts 'got a page'
      puts page.inspect
      f = page.forms[1]
      puts 'got a form'
      puts f
      f.add_field!('activity[visibility]', visibility)
      puts 'set activity visiblity'
      @agent.submit(f)
      log.debug 'Changed visibility'
    end
  end
end
