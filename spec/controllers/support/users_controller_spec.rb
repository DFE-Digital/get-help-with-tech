require 'rails_helper'

RSpec.describe Support::UsersController, type: :controller do
  describe '#create' do
    context 'for support users', versioning: true do
      let(:responsible_body) { create(:local_authority) }
      let(:dfe_user) { create(:dfe_user) }

      before do
        sign_in_as dfe_user
      end

      def perform_create!
        post :create, params: { responsible_body_id: responsible_body.id,
                                user: attributes_for(:user),
                                pilot: 'devices' }
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

      context 'if RB only has one school and this is the first user' do
        let!(:school) { create(:school, responsible_body: responsible_body) }

        it 'sets user.school to the school' do
          perform_create!

          user = User.last
          expect(user.school).to eql(school)
        end

        it 'creates preorder on the school with school to order' do
          perform_create!
          school.reload

          expect(school.preorder_information).to be_present
          expect(school.preorder_information.who_will_order_devices).to eql('school')
        end
      end
    end

    it 'is forbidden for MNO users' do
      sign_in_as create(:mno_user)

      post :create, params: { responsible_body_id: 1, user: { some: 'data' }, pilot: 'devices' }

      expect(response).to have_http_status(:forbidden)
    end

    it 'is forbidden for responsible body users' do
      sign_in_as create(:trust_user)

      post :create, params: { responsible_body_id: 1, user: { some: 'data' }, pilot: 'devices' }

      expect(response).to have_http_status(:forbidden)
    end

    it 'redirects to / for unauthenticated users' do
      post :create, params: { responsible_body_id: 1, user: { some: 'data' }, pilot: 'devices' }

      expect(response).to redirect_to(sign_in_path)
    end
  end
end
