require 'rails_helper'

RSpec.describe ResponsibleBody::UsersController do
  let(:local_authority) { create(:local_authority) }
  let(:other_local_authority) { create(:local_authority) }

  let(:rb_user) { create(:local_authority_user, responsible_body: local_authority) }
  let(:rb_user_2) { create(:local_authority_user, responsible_body: local_authority) }
  let(:user_from_other_rb) { create(:local_authority_user, responsible_body: other_local_authority) }

  describe '#edit' do
    context 'logged in as a RB user' do
      before do
        sign_in_as rb_user
      end

      it 'lets me access myself' do
        get :edit, params: { id: rb_user.id }
        expect(response).to have_http_status(:ok)
      end

      it 'lets me access another user from the same RB' do
        get :edit, params: { id: rb_user_2.id }
        expect(response).to have_http_status(:ok)
      end

      it 'does not let me access a user from a different RB' do
        get :edit, params: { id: user_from_other_rb.id }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'logged in as non-RB user' do
      let(:mno_user) { create(:mno_user) }

      before do
        sign_in_as mno_user
      end

      it 'does not let me access a responsible_body user' do
        get :edit, params: { id: user_from_other_rb.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe '#create' do
    context 'as rb user' do
      before do
        sign_in_as rb_user
      end

      def perform_create!
        post :create, params: {
          id: local_authority.id,
          user: {
            full_name: 'John Doe',
            email_address: 'john.doe@example.com',
            phone_number: '020 1',
          },
        }
      end

      it 'creates a user record' do
        expect { perform_create! }.to change(User, :count).by(1)
      end

      it 'sets user with orders_devices as true' do
        perform_create!

        user = User.last
        expect(user.orders_devices).to be_truthy
      end
    end

    context 'support user impersonating' do
      let(:support_user) { create(:support_user) }

      before do
        sign_in_as support_user
        impersonate rb_user
      end

      it 'returns forbidden' do
        post :create, params: {
          id: local_authority.id,
          user: {
            full_name: 'John Doe',
            email_address: 'john.doe@example.com',
            phone_number: '020 1',
          },
        }

        expect(response).to be_forbidden
      end
    end
  end

  describe '#update' do
    context 'support user impersonating' do
      let(:support_user) { create(:support_user) }

      before do
        sign_in_as support_user
        impersonate rb_user
      end

      it 'returns forbidden' do
        put :update, params: {
          id: rb_user_2.id,
          user: {
            full_name: 'John Doe',
            email_address: 'john.doe@example.com',
            phone_number: '020 1',
          },
        }

        expect(response).to be_forbidden
      end
    end
  end
end
