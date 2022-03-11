require 'rails_helper'

RSpec.describe School::UsersController, type: :controller do
  let(:school_user) { create(:school_user) }
  let(:school) { school_user.school }
  let(:new_user) { build(:school_user, school: school) }
  let(:request_data) do
    { urn: school.urn, user: { full_name: new_user.full_name, email_address: new_user.email_address, orders_devices: false } }
  end

  describe '#update' do
    context 'when support user impersonating' do
      let(:support_user) { create(:support_user) }

      before do
        sign_in_as support_user
        impersonate school_user
      end

      it 'returns forbidden' do
        put :update, params: { urn: school.urn, id: school_user.id, user: { full_name: 'new name' } }
        expect(response).to be_forbidden
      end
    end
  end
end
