require 'rails_helper'

describe StreamsController, type: :controller do
  let(:session_data) { { access_token: "2lo9w8eadrdk58dxhqz3wbsszayjdh", expires_in: 15710 } }
  let(:session) { create(:session, data: session_data) }
  before { allow(::Sessions::Manage).to receive(:call).and_return(double(error: nil)) }

  describe 'no session' do
    let(:actions) { { index: {}, show: { id: '1234321' } } }
    it 'redirects to oauth page' do
      actions.each do |action, params|
        get(action, session: { _session_id: nil }, params: params)
        expect(response).to have_http_status :found
      end
    end
  end

  describe 'GET#index' do
    def search_streamer(cassette, q)
      VCR.use_cassette(cassette) do
        get :index, params: { q: q }, session: { _session_id: session.id }
      end
    end

    context 'without search' do
      it 'renders template' do
        search_streamer('search-channels', nil)
        expect(response).to render_template(:index)
      end
    end

    context 'with search' do
      it 'renders template' do
        search_streamer('search-channels', 'fabric')
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET#show' do
    def show_stream(cassette)
      VCR.use_cassette(cassette) do
        get :show, params: { id: '456654928' }, session: { _session_id: session.id }
      end
    end

    it 'renders template' do
      show_stream('chanel-details-found')
      expect(response).to render_template(:show)
    end
  end
end
