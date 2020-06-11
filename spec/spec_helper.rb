require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.filter_sensitive_data 'TOKEN' do |interaction|
    auth = interaction.request.headers['Authorization']
    puts auth if auth != nil
    auth
  end
end
