require 'rails_helper'

RSpec.describe School::UsersController, type: :controller do
  let(:school_user) { create(:school_user) }
  let(:new_user) { build(:school_user, school: school_user.school) }

  context 'when authenticated' do
    before do
      sign_in_as school_user
    end

    describe 'create' do
      let(:request_data) do
        { urn: school_user.school.urn, user: { full_name: new_user.full_name, email_address: new_user.email_address, orders_devices: false } }
      end

      it 'adds the new user to the school' do
        expect {
          post :create, params: request_data
        }.to change { school_user.school.users.count }.by(1)
      end

      it 'sends an email to the new user' do
        expect {
          post :create, params: request_data
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob).once
      end
    end
  end
end
