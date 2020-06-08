require_relative '../src/privacy_client'
describe 'privacy client' do
  it 'initializes' do
    client = SecretStrava::PrivacyClient.new({})
  end
end