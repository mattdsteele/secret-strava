require_relative './spec_helper'
require_relative '../src/privacy_client'
describe 'privacy client', :vcr do
  it 'initializes' do
    client = SecretStrava::PrivacyClient.new
  end
end
