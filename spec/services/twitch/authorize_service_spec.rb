require 'rails_helper'

describe ::Twitch::AuthorizeService do
  describe '::url' do
    let(:check_value)    { 'random-check-value' }
    let(:mock_url_query) { '?key1=val1&key2=val2' }
    let(:expected_url)   { "https://id.twitch.tv/oauth2/authorize#{mock_url_query}" }
    subject { described_class.url(check_value) }
    before do
      mock_url = mock_url_query
      described_class.define_singleton_method(:url_query) {|_params| mock_url }
    end
    it 'builds sanitized autorizate url' do
      is_expected.to eq expected_url
    end
  end

  describe '::url_params' do
    let(:expected_keys) do
      %i[
        force_verify
        response_type
        scope
        client_id
        redirect_uri
      ]
    end
    subject do
      described_class
        .send(:url_params)
        .select { |_, val| val.present? }
        .values
        .length
    end
    it 'builds url query using api params and credentials' do
      is_expected.to be expected_keys.length
    end
  end
end
