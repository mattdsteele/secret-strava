require_relative '../src/google_secrets_config'

describe 'privacy client' do
  it 'loads config stuff ok' do
    c = SecretStrava::GoogleSecretsConfig.new
    expect(c.test_secret).to eq '12345'
  end
  it 'returns nil if value set' do
    c = SecretStrava::GoogleSecretsConfig.new
    expect(c.foo).to be_nil
  end
end
