require 'rails_helper'

RSpec.describe ResponsibleBody::Internet::HomeController do
  render_views

  let(:user) { create(:local_authority_user) }

  before { sign_in_as user }

  describe '#show' do
    before { get :show }

    specify { expect(response).to be_successful }
    specify { expect(assigns(:responsible_body)).to be_present }
    specify { expect(assigns(:responsible_body)).to eq(user.responsible_body) }
  end
end
