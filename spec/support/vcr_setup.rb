require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = Rails.root.join('spec', 'fixtures', 'vcr_cassettes')
  c.hook_into :faraday
  c.default_cassette_options = { record: :new_episodes }
  c.configure_rspec_metadata!
end