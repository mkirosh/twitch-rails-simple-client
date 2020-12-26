require 'rails_helper'

RSpec.describe Session, type: :model do
  let(:token) { 'token-test' }
  let(:refresh_token) { 'refresh-token-test' }
  let(:expires_in) { 14_411 }
  let(:session_data) { { access_token: token, expires_in: expires_in, refresh_token: refresh_token } }
  let(:session_attr) { { token: token, expires_in: expires_in, refresh_token: refresh_token } }

  describe 'instance attribute readers' do
    context 'when session data is present' do
      subject! { build(:session, data: session_data) }
      it 'returns correct values' do
        session_attr.each do |attr_key, value|
          expect(subject.send(attr_key)).to eq value
        end
      end
    end
    context 'when session data is blank' do
      subject! { build(:session) }
      it 'returns correct values' do
        session_attr.each_key do |attr_key|
          expect(subject.send(attr_key)).to eq nil
        end
      end
    end
  end
end
