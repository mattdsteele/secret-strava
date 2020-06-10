require_relative '../src/config'

describe 'config' do
  it 'loads config stuff ok' do
    c = SecretStrava::Config.new
    expect(c.auth_host).to eq 'strava.steele.blue'
  end
end
