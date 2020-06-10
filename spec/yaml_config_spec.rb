require_relative '../src/yaml_config'

describe 'privacy client' do
  it 'loads config stuff ok' do
    c = SecretStrava::YamlConfig.new
    expect(c.auth_host).to eq 'strava.steele.blue'
    expect(c.auth_oauthpath).to eq '/auth-response'
  end
  it 'returns nil if value set' do
    c = SecretStrava::YamlConfig.new
    expect(c.foo).to be_nil
    expect(c.foo_bar).to be_nil
  end
end
