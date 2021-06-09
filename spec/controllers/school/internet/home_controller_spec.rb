require 'rails_helper'

RSpec.describe School::Internet::HomeController do
  let(:user) { create(:school_user) }
  let(:school) { user.school }

  before { sign_in_as user }

  describe '#show' do
    before { get :show, params: { urn: school.urn } }

    specify { expect(response).to be_successful }
    specify { expect(assigns(:responsible_body)).to be_present }
    specify { expect(assigns(:responsible_body)).to eq(school.responsible_body) }
  end
end
