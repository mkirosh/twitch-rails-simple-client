require 'rails_helper'

describe CheckCode, type: :model do
  describe '::new' do
    subject { create(:check_code).code  }
    it 'creates and generates code' do
      is_expected.not_to be nil
    end
  end  
end
