require_relative './spec_helper'
require_relative '../src/config'

describe 'config', :vcr do
  it 'loads config from yml' do
    c = SecretStrava::Config.new
    expect(c.auth_host).to eq 'strava.steele.blue'
  end
  it 'loads from env' do
    c = SecretStrava::Config.new
    ENV['FOO'] = 'bar'
    expect(c.foo).to eq 'bar'
    ENV['FOO_BAR'] = 'baz'
    expect(c.foo_bar).to eq 'baz'
  end
end
