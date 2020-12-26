require 'rails_helper'
describe SessionsController, type: :controller do
  describe 'GET#new' do
    context 'when non authorized' do
      it 'request is treated as unauthorized' do
        get :new
        expect(response).to have_http_status :unauthorized
      end
    end
    
    context 'when authorized' do
      RSpec.shared_examples 'failed session attempt' do |with_status: :unauthorized|
        it 'request is treated as unauthorized' do
          expect(response).to have_http_status with_status
        end
        it 'does not set session cookie' do
          expect(session[:_session_id]).to be nil
        end
        it 'does not create a new session' do
          expect(controller.current_session).to be nil
        end
      end

      def get_token(code, cassette, state = nil)
        VCR.use_cassette(cassette) do
          get :new, params: { code: code, state: state }
        end
      end

      context 'but state is missing' do
        before { get_token('ti3r80uxxon1yfii1i73a185d2dksx', 'token-request-valid') }
        include_examples 'failed session attempt'
      end

      context 'but state is incorrect' do
        before { get_token('ti3r80uxxon1yfii1i73a185d2dksx', 'token-request-valid', 'incorrect-check-code') }
        include_examples 'failed session attempt'
      end

      context 'but state is archived' do
        before do
          create(:check_code, code: 'incorrect-check-code', archived: true)
          get_token('ti3r80uxxon1yfii1i73a185d2dksx', 'token-request-valid', 'incorrect-check-code')
        end
        include_examples 'failed session attempt'
      end

      context 'but state is expired' do
        before do
          state = create(:check_code, code: 'incorrect-check-code', archived: false, created_at: 3.minutes.ago)
          get_token('ti3r80uxxon1yfii1i73a185d2dksx', 'token-request-valid', state.code)
        end
        include_examples 'failed session attempt'
      end

      context 'but token request fails' do
        before do
          state = create(:check_code, code: 'correct-check-code', archived: false)
          get_token('=fdmg6a94o0mx8expiiwdxd7bcp4cmb', 'token-request-invalid', state.code)
        end
        include_examples 'failed session attempt', with_status: :unprocessable_entity
      end

      context 'and token assigned' do
        let(:state) { create(:check_code, code: 'correct-check-code', archived: false) }

        it 'redirect_to streams_path' do
          get_token('ti3r80uxxon1yfii1i73a185d2dksx', 'token-request-valid', state.code)
          expect(response).to redirect_to streams_path
        end

        it 'sets session cookie' do
          expect(session[:_session_id]).to be nil
          get_token('ti3r80uxxon1yfii1i73a185d2dksx', 'token-request-valid', state.code)
          expect(session[:_session_id]).not_to be nil
        end
        
        it 'does create a new session' do
          get_token('ti3r80uxxon1yfii1i73a185d2dksx', 'token-request-valid', state.code)
          expect(controller.current_session.token).not_to be nil
        end
      end
    end
  end
end
