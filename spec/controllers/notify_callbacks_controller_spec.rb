require 'rails_helper'

RSpec.describe NotifyCallbacksController do
  let(:user) { create(:user) }
  let(:audit) { create(:email_audit, user:, govuk_notify_id: SecureRandom.uuid) }

  let(:payload) do
    {
      id: SecureRandom.uuid,
      reference: nil,
      to: user.email_address,
      status: 'delivered', # delivered, permanent-failure, temporary-failure or technical-failure
      created_at: '2017-05-14T12:15:30.000000Z',
      completed_at:	'2017-05-14T12:15:30.000000Z', # or null
      sent_at: '2017-05-14T12:15:30.000000Z', # or null
      notification_type: 'email',
    }
  end

  let(:govuk_notify_settings) { OpenStruct.new(callback_bearer_token: Digest::SHA256.hexdigest('password')) }

  before do
    allow(Settings).to receive(:govuk_notify).and_return(govuk_notify_settings)
  end

  describe '#create' do
    context 'without auth' do
      it 'returns a 401' do
        post :create, params: payload, format: :json
        expect(response).to be_unauthorized
      end

      it 'does not create an email audit' do
        expect {
          post :create, params: payload, format: :json
        }.not_to(change { EmailAudit.count })
      end
    end

    context 'with auth' do
      before do
        request.headers['Authorization'] = 'Bearer password'
      end

      it 'creates an email audit' do
        expect {
          post :create, params: payload, format: :json
        }.to change { EmailAudit.count }.by(1)

        audit = EmailAudit.last

        expect(audit.email_address).to eql(user.email_address)
      end

      context 'when we do not have the email address' do
        let(:payload) do
          {
            id: SecureRandom.uuid,
            reference: nil,
            to: 'do.not.exist@example.com',
            status: 'delivered', # delivered, permanent-failure, temporary-failure or technical-failure
            created_at: '2017-05-14T12:15:30.000000Z',
            completed_at:	'2017-05-14T12:15:30.000000Z', # or null
            sent_at: '2017-05-14T12:15:30.000000Z', # or null
            notification_type: 'email',
          }
        end

        it 'does not store the audit' do
          expect {
            post :create, params: payload, format: :json
          }.not_to(change { EmailAudit.count })
        end
      end

      context 'when we have associated audit thru govuk_notify_id' do
        let(:payload) do
          {
            id: audit.govuk_notify_id,
            reference: nil,
            to: user.email_address,
            status: 'delivered', # delivered, permanent-failure, temporary-failure or technical-failure
            created_at: '2017-05-14T12:15:30.000000Z',
            completed_at:	'2017-05-14T12:15:30.000000Z', # or null
            sent_at: '2017-05-14T12:15:30.000000Z', # or null
            notification_type: 'email',
          }
        end

        it 'updates the audit' do
          expect {
            post :create, params: payload, format: :json
          }.to change { audit.reload.govuk_notify_status }.from(nil).to('delivered')
        end
      end

      context 'when an sms callback' do
        let(:payload) do
          {
            id: SecureRandom.uuid,
            reference: nil,
            to: user.email_address,
            status: 'delivered', # delivered, permanent-failure, temporary-failure or technical-failure
            created_at: '2017-05-14T12:15:30.000000Z',
            completed_at:	'2017-05-14T12:15:30.000000Z', # or null
            sent_at: '2017-05-14T12:15:30.000000Z', # or null
            notification_type: 'sms',
          }
        end

        it 'is ignored' do
          expect {
            post :create, params: payload, format: :json
          }.not_to(change { EmailAudit.count })
        end
      end
    end
  end
end
