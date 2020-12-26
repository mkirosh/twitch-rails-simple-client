require 'rails_helper'
describe ::Sessions::Manage do
  def manage
    VCR.use_cassette(cassette) do
      described_class.call(session: session, cookies: cookies).error
    end
  end
  let(:session_data) {
    {
      access_token: 'm1p9yk8ezz778evd9h225jjfl8i42r',
      expires_in: 14_411, # expires in 4 hours
      refresh_token: 'some-random-token',
      scope: %w[chat:edit chat:read],
      token_type: 'bearer'
    }
  }
  let(:cookies) { { _session_id: session.id } }
  subject! { manage }

  describe '::call' do
    RSpec.shared_examples 'session life finished' do |with_error: ''|
      it 'returns errors' do
        is_expected.to eq with_error
      end
      it 'deletes session' do
        expect { session.reload.id }.to raise_error ::ActiveRecord::RecordNotFound
      end
      it 'clears session cookie' do
        expect(cookies[:_session_id]).to be nil
      end
    end

    RSpec.shared_examples 'session life continues' do 
      it 'keeps the session cookie' do
        expect(cookies[:_session_id]).to be session.reload.id
      end
    end

    context 'when session and token ared valid' do
      let(:session) { create(:session, data: session_data) }
      let(:cassette) { 'valid-session-management' }
      include_examples 'session life continues'
    end

    context 'when session older than 7 days' do
      let(:session) { create(:session, data: session_data, created_at: 8.days.ago) }
      let(:cassette) { 'valid-session-management' }
      include_examples 'session life finished', with_error: 'Session expired'
    end

    context 'when session disconected by user' do
      let(:session) { create(:session, data: session_data) }
      let(:cassette) { 'invalid-session-management' }
      include_examples 'session life finished', with_error: 'Token invalidated'
    end

    context 'when session token expired' do
      context 'and token requets fails' do
        let(:session) { create(:session, data: session_data, created_at: 6.hours.ago) }
        let(:cassette) { 'invalid-refresh-session-management' }
        include_examples 'session life finished', with_error: 'Token refresh unauthorized'
      end

      context 'and token request succeeds' do
        let(:session) { create(:session, data: session_data, created_at: 6.hours.ago) }
        let(:cassette) { 'valid-session-management' }
        include_examples 'session life continues'
      end
    end
  end
end
