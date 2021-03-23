require 'rails_helper'

RSpec.describe Support::EmailAuditsController do
  let(:support_user) { create(:support_user) }

  describe '#index' do
    before do
      sign_in_as support_user
    end

    it 'returns with status code 200' do
      get :index
      expect(response).to be_successful
    end
  end
end
