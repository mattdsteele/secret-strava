require_relative '../src/config'

describe 'privacy client' do
  it 'loads config stuff ok' do
    c = SecretStrava::Config.parse
    expect(c['auth']['host']).to eq 'strava.steele.blue'
  end
end
