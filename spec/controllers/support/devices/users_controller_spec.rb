require 'rails_helper'

RSpec.describe Support::Devices::UsersController do
  let(:support_user) { create(:support_user) }
  let(:school) { create(:school) }

  before do
    sign_in_as support_user
  end

  describe '#new' do
    it 'loads' do
      get :new, params: { school_urn: school.urn }
      expect(response).to be_successful
    end
  end

  describe '#create' do
    context 'happy path' do
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

      it 'sets attributes correctly' do
        post!
        record = User.last
        expect(record.orders_devices).to be_falsey
      end

      it 'redirects back to the school' do
        post!
        expect(response).to redirect_to support_devices_school_path(urn: school.urn)
      end

      it 'sends out an email', sidekiq: true do
        expect { post! }.to change {
          ActionMailer::Base.deliveries.size
        }.by(1)
      end
    end

    context 'when there is an error' do
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
  end
end
