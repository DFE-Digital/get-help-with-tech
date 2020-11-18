require 'rails_helper'

RSpec.describe Support::Schools::UsersController do
  let(:support_user) { create(:support_user) }
  let(:school) { create(:school) }
  let(:existing_user) { create(:school_user, school: school) }

  describe '#new' do
    it 'is successful for support users' do
      sign_in_as support_user
      get :new, params: { school_urn: school.urn }
      expect(response).to be_successful
    end

    it 'is forbidden for computacenter users' do
      expect {
        get :new, params: { school_urn: school.urn }
      }.to be_forbidden_for(create(:computacenter_user))
    end
  end

  describe '#create' do
    context 'for a support user, with valid new user details' do
      before do
        sign_in_as support_user
      end

      def post!
        post :create, params: {
          school_urn: school.urn,
          user: {
            full_name: 'John Doe',
            email_address: 'john@example.com',
            orders_devices: '0',
          },
        }
      end

      it 'creates a new user' do
        expect { post! }.to change(User, :count).by(1)
      end

      it 'associates user and school' do
        post!

        expect(User.last.school).to eql(school)
      end

      it 'sets attributes correctly' do
        post!
        record = User.last
        expect(record.orders_devices).to be_falsey
      end

      it 'redirects back to the school' do
        post!
        expect(response).to redirect_to support_school_path(urn: school.urn)
      end

      it 'sends out an email', sidekiq: true do
        expect { post! }.to change {
          ActionMailer::Base.deliveries.size
        }.by(1)
      end
    end

    context 'for a support user, when there is an error' do
      before do
        sign_in_as support_user
      end

      def post!
        post :create, params: {
          school_urn: school.urn,
          user: {
            full_name: '',
            email_address: 'john@example.com',
            orders_devices: '0',
          },
        }
      end

      it 'does not create a user' do
        expect { post! }.not_to change(User, :count)
      end

      it 're-renders :new' do
        post!
        expect(response).to render_template(:new)
      end
    end

    it 'is forbidden for a computacenter user' do
      expect {
        post :create, params: {
          school_urn: school.urn,
          user: {
            full_name: 'John Doe',
            email_address: 'john@example.com',
            orders_devices: '0',
          },
        }
      }.to be_forbidden_for(create(:computacenter_user))
    end
  end

  describe '#edit' do
    it 'is successful for support users' do
      expect {
        get :edit, params: { school_urn: school.urn, id: existing_user.id }
      }.to receive_status_ok_for(support_user)
    end

    it 'is forbidden for computacenter users' do
      expect {
        get :edit, params: { school_urn: school.urn, id: existing_user.id }
      }.to be_forbidden_for(create(:computacenter_user))
    end
  end

  describe '#update' do
    it 'is successful for support users' do
      sign_in_as support_user

      put :update, params: {
        school_urn: school.urn,
        id: existing_user.id,
        user: {
          full_name: 'someone_else',
        },
      }

      expect(response).to redirect_to(support_school_path(school))
    end

    it 'is forbidden for computacenter users' do
      expect {
        put :update, params: {
          school_urn: school.urn,
          id: existing_user.id,
          user: {
            full_name: 'someone_else',
          },
        }
      }.to be_forbidden_for(create(:computacenter_user))
    end
  end

  describe '#destroy' do
    let(:user) { create(:school_user) }
    let(:school) { user.school }

    context 'for support users' do
      before do
        sign_in_as support_user
      end

      it 'sets user deleted_at timestamp' do
        delete :destroy, params: { school_urn: school.urn, id: user.id }
        expect(user.reload.deleted_at).to be_present
      end

      it 'redirects back to the school' do
        delete :destroy, params: { school_urn: school.urn, id: user.id }
        expect(response).to redirect_to(support_school_path(school))
      end
    end

    context 'for computacenter users' do
      it 'is forbidden' do
        expect {
          delete :destroy, params: { school_urn: school.urn, id: user.id }
        }.to be_forbidden_for(create(:computacenter_user))
      end
    end
  end
end
