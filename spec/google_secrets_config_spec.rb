require_relative './spec_helper'
require_relative '../src/google_secrets_config'

describe 'google secrets config', :vcr do
  it 'loads config stuff ok' do
    c = SecretStrava::GoogleSecretsConfig.new
    expect(c).to_not be_nil
  end
end
