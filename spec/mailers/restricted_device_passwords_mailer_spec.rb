require 'rails_helper'

RSpec.describe RestrictedDevicePasswordsMailer, type: :mailer do
  let(:user) { create(:school_user) }
  let(:organisation_name) { 'School Name' }
  let(:last_email) { ActionMailer::Base.deliveries.last }
  let(:link_to_file) { Notifications.prepare_upload(StringIO.new(''), true) }

  let(:email) do
    described_class.with(user:, organisation_name:, link_to_file:)
                   .notify_restricted_devices
  end

  before do
    allow(described_class).to receive(:template_mail).and_return({})
  end

  describe '#notify_restricted_devices' do
    it 'adds an email audit record' do
      expect { email.deliver_now }.to change { EmailAudit.count }.by(1)
    end

    it 'sets the correct values on the email audit record' do
      email.deliver_now
      expect(EmailAudit.last).to have_attributes(message_type: 'notify_restricted_devices',
                                                 template: Settings.govuk_notify.templates.devices.notify_restricted_devices,
                                                 user_id: user.id,
                                                 email_address: user.email_address)
    end

    it 'enqueues mailer job with #deliver_later' do
      expect { email.deliver_later }.to have_enqueued_job.on_queue('mailers')
    end

    it 'sends mail with #deliver_now' do
      expect { email.deliver_now }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end

    it 'passes email_audit id as reference to notify' do
      email.deliver_now

      expect(last_email.to).to contain_exactly(user.email_address)
    end

    it 'targets the right email address' do
      email.deliver_now

      audit = EmailAudit.last

      expect(last_email.header['reference'].value).to eql(audit.id.to_s)
    end
  end
end
