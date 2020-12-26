require 'rails_helper'
describe ::Sessions::Authenticate do
  let(:cookies) { { _session_id: nil } }
  let(:valid_state) { create(:check_code, archived: false) }
  let(:invalid_state) { create(:check_code, archived: true) }
  def authentication(session:, check:, cookies:, cassette:)
    VCR.use_cassette(cassette) do
      described_class.call({ session: session, check: check, cookies: cookies })
    end
  end
  subject { authentication({ session: session, check: check, cookies: cookies, cassette: cassette }) }
  describe '::call' do
    RSpec.shared_examples 'unauthorized token request' do |raise_exception: ::Twitch::AuthorizeService::UnauthorizedException|
      it 'raise unauthorized exception' do
        expect { subject }.to raise_exception raise_exception
      end
      it 'cookies remain clean' do
        expect(cookies[:_session_id]).to be nil
      end
    end
    context 'when check blank' do
      let(:session) { build(:session, code: 'ti3r80uxxon1yfii1i73a185d2dksx') }
      let(:cassette) { 'token-request-valid' }
      let(:check) { nil }
      include_examples 'unauthorized token request'
    end
    context 'when check does not exist' do
      let(:session) { build(:session, code: 'ti3r80uxxon1yfii1i73a185d2dksx') }
      let(:cassette) { 'token-request-valid' }
      let(:check) { 'invalid-state-check' }
      include_examples 'unauthorized token request'
    end
    context 'when check is archived' do
      let(:session) { build(:session, code: 'ti3r80uxxon1yfii1i73a185d2dksx') }
      let(:cassette) { 'token-request-valid' }
      let(:check) { invalid_state.code }
      include_examples 'unauthorized token request'
    end
    context 'when check is expired' do
      let(:session) { build(:session, code: 'ti3r80uxxon1yfii1i73a185d2dksx') }
      let(:cassette) { 'token-request-valid' }
      let(:check) {
        state = valid_state
        state.update!(created_at: 2.minutes.ago)
        state.code
      }
      include_examples 'unauthorized token request'
    end
    context 'when token request fails' do
      let(:session) { build(:session, code: '=fdmg6a94o0mx8expiiwdxd7bcp4cmb') }
      let(:cassette) { 'token-request-invalid' }
      let(:check) { valid_state.code }
      include_examples 'unauthorized token request', raise_exception: ::ActiveRecord::RecordInvalid
    end
    context 'when token  succeeds' do
      let(:session) { build(:session, code: 'ti3r80uxxon1yfii1i73a185d2dksx') }
      let(:cassette) { 'token-request-valid' }
      let(:check) { valid_state.code }
      subject! { super() }
      it 'session is persisted with token' do
        expect(session.persisted?).to be true
      end
      it 'session cookie is set' do
        expect(cookies[:_session_id]).not_to be nil
      end
      it 'session cookie matches the db record' do
        expect(cookies[:_session_id]).to be session.id
      end
    end
  end
end
