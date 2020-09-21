require 'rails_helper'

RSpec.describe CreateUserService do
  let(:last_email) { ActionMailer::Base.deliveries.last }

  describe 'invite_responsible_body_user' do
    let(:trust) { create(:trust) }

    context 'given valid user params' do
      let(:valid_params) do
        {
          full_name: 'Vlad Valid',
          email_address: 'vlad@example.com',
          telephone: '01234 567890',
          responsible_body_id: trust.id,
        }
      end
      let(:result) { CreateUserService.invite_responsible_body_user(valid_params) }

      it 'creates a user with the given params' do
        expect { result }.to change(User, :count).by(1)
        expect(User.last).to have_attributes(valid_params)
      end

      it 'sends the correct email' do
        expect { perform_enqueued_jobs { result } }.to change(ActionMailer::Base.deliveries, :size).by(1)
        expect(last_email.to[0]).to eq(valid_params[:email_address])
        expect(last_email.header['template-id'].value).to eq(Settings.govuk_notify.templates.devices.invite_responsible_body_user)
      end

      it 'returns the user' do
        expect(result).to be_a(User)
        expect(result).to have_attributes(valid_params)
      end
    end

    context 'given invalid user params' do
      let(:invalid_params) do
        {
          full_name: '.',
          email_address: 'dunno',
          responsible_body_id: nil,
        }
      end
      let(:result) { CreateUserService.invite_responsible_body_user(invalid_params) }

      it 'does not create a user with the given params' do
        expect { result }.not_to change(User, :count)
      end

      it 'does not send any email' do
        expect { perform_enqueued_jobs { result } }.not_to change(ActionMailer::Base.deliveries, :size)
      end

      it 'returns the user unpersisted, with errors' do
        expect(result).to be_a(User)
        expect(result).to have_attributes(invalid_params)
        expect(result.errors.full_messages).not_to be_empty
      end
    end
  end

  describe 'invite_school_user' do
    let(:school) { create(:school) }

    context 'given valid user params' do
      let(:valid_params) do
        {
          full_name: 'Vlad Valid',
          email_address: 'vlad@example.com',
          telephone: '01234 567890',
          school_id: school.id,
        }
      end
      let(:result) { CreateUserService.invite_school_user(valid_params) }

      it 'creates a user with the given params' do
        expect { result }.to change(User, :count).by(1)
        expect(User.last).to have_attributes(valid_params)
      end

      it 'sends the correct email' do
        expect { perform_enqueued_jobs { result } }.to change(ActionMailer::Base.deliveries, :size).by(1)
        expect(last_email.to[0]).to eq(valid_params[:email_address])
        expect(last_email.header['template-id'].value).to eq(Settings.govuk_notify.templates.devices.school_nominated_contact)
      end

      it 'returns the user' do
        expect(result).to be_a(User)
        expect(result).to have_attributes(valid_params)
      end
    end

    context 'given invalid user params' do
      let(:invalid_params) do
        {
          full_name: '.',
          email_address: 'dunno',
          school_id: nil,
        }
      end
      let(:result) { CreateUserService.invite_school_user(invalid_params) }

      it 'does not create a user with the given params' do
        expect { result }.not_to change(User, :count)
      end

      it 'does not send any email' do
        expect { perform_enqueued_jobs { result } }.not_to change(ActionMailer::Base.deliveries, :size)
      end

      it 'returns the user unpersisted, with errors' do
        expect(result).to be_a(User)
        expect(result).to have_attributes(invalid_params)
        expect(result.errors.full_messages).not_to be_empty
      end
    end
  end
end
