require 'rails_helper'

RSpec.describe Support::ResponsibleBodies::UsersController, type: :controller do
  let(:dfe_user) { create(:dfe_user) }
  let(:responsible_body) { create(:local_authority) }

  describe '#create' do
    context 'for support users', versioning: true do
      before do
        sign_in_as dfe_user
      end

      def perform_create!
        post :create, params: { responsible_body_id: responsible_body.id,
                                user: attributes_for(:user) }
      end

      it 'creates users' do
        expect { perform_create! }.to change(User, :count).by(1)
      end

      it 'sets orders_devices to true' do
        perform_create!

        user = User.last
        expect(user.orders_devices).to be_truthy
      end

      it 'does not set the school on the user' do
        perform_create!

        user = User.last
        expect(user.school).to be_blank
      end

      it 'audits changes with reference to user that requested the changes' do
        perform_create!

        expect(User.last.versions.last.whodunnit).to eql("User:#{dfe_user.id}")
      end
    end

    it 'is forbidden for MNO users' do
      expect {
        post :create, params: { responsible_body_id: responsible_body.id, user: { some: 'data' } }
      }.to be_forbidden_for(create(:mno_user))
    end

    it 'is forbidden for responsible body users' do
      expect {
        post :create, params: { responsible_body_id: responsible_body.id, user: { some: 'data' } }
      }.to be_forbidden_for(create(:trust_user))
    end

    it 'redirects to / for unauthenticated users' do
      post :create, params: { responsible_body_id: responsible_body.id, user: { some: 'data' } }

      expect(response).to redirect_to(sign_in_path)
    end
  end

  describe '#destroy' do
    let(:user) { create(:trust_user) }
    let(:rb) { user.responsible_body }

    before do
      sign_in_as dfe_user
    end

    it 'sets user deleted_at timestamp' do
      delete :destroy, params: { responsible_body_id: rb.id, id: user.id }
      expect(user.reload.deleted_at).to be_present
    end

    it 'redirects back to the RB' do
      delete :destroy, params: { responsible_body_id: rb.id, id: user.id }
      expect(response).to redirect_to(support_responsible_body_path(rb))
    end
  end
end
