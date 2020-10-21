require 'rails_helper'

RSpec.describe ResponsibleBody::BaseController do
  controller do
    def index
      render plain: 'hello'
    end
  end

  context 'when user is a single_academy_trust user' do
    let(:user) { create(:single_academy_trust_user) }

    before do
      sign_in_as user
    end

    it 'returns forbidden' do
      get :index
      expect(response).to be_forbidden
    end
  end
end
