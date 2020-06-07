require "mechanize"

class PrivacyClient
  def initialize(options)
    @user = options[:user]
    @pass = options[:password]
  end
  def auth
    agent = Mechanize.new
    page = agent.get('https://strava.com/login')
    f = page.forms.first
    f.email = @user
    f.password = @pass
    page2 = agent.submit(f)
    @agent = agent
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
    url = "https://www.strava.com/activities/#{activity_id}/edit"
    page = @agent.get(url)
    f = page.forms[1]
    f.add_field!('activity[visibility]', visibility)
    @agent.submit(f)
  end
end