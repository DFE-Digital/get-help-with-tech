require 'rails_helper'

RSpec.describe CanOrderDevicesMailer, type: :mailer do
  let(:school) { create(:school) }
  let(:user) { create(:school_user) }

  before do
    allow(described_class).to receive(:template_mail).and_return({})
  end

  describe '#user_can_order' do
    it 'adds an email audit record' do
      expect {
        described_class.with(user: user, school: school).user_can_order.deliver_now
      }.to change { EmailAudit.count }.by(1)
    end

    it 'sets the correct values on the email audit record' do
      described_class.with(user: user, school: school).user_can_order.deliver_now
      expect(EmailAudit.last).to have_attributes(message_type: 'can_order',
                                                 template: Settings.govuk_notify.templates.devices.can_order_devices,
                                                 user_id: user.id,
                                                 school_id: school.id,
                                                 email_address: user.email_address)
    end

    it 'enqueues mailer job with #deliver_later' do
      expect {
        described_class.with(user: user, school: school).user_can_order.deliver_later
      }.to have_enqueued_job.on_queue('mailers')
    end

    it 'sends mail with #deliver_now' do
      expect {
        described_class.with(user: user, school: school).user_can_order.deliver_now
      }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end

    it 'passes email_audit id as reference to notify' do
      described_class.with(user: user, school: school).user_can_order.deliver_now

      audit = EmailAudit.last
      mail = ActionMailer::Base.deliveries.last
      expect(mail.header['reference'].value).to eql(audit.id.to_s)
    end

    context 'when user is deleted' do
      let(:user) { create(:school_user, deleted_at: 1.second.ago) }

      it 'enqueues mailer job with #deliver_later' do
        expect {
          described_class.with(user: user, school: school).user_can_order.deliver_later
        }.to have_enqueued_job.on_queue('mailers')
      end

      it 'does not send mail with #deliver_now' do
        expect {
          described_class.with(user: user, school: school).user_can_order.deliver_now
        }.not_to change(ActionMailer::Base.deliveries, :size)
      end
    end
  end

  describe '#user_can_order_in_fe_college' do
    let(:responsible_body) { create(:further_education_college, :new_fe_wave) }
    let(:school) { create(:fe_school, responsible_body: responsible_body) }
    let(:user) { create(:school_user, school: school) }

    it 'adds an email audit record' do
      expect {
        described_class.with(user: user, school: school).user_can_order_in_fe_college.deliver_now
      }.to change { EmailAudit.count }.by(1)
    end

    it 'sets the correct values on the email audit record' do
      described_class.with(user: user, school: school).user_can_order_in_fe_college.deliver_now
      expect(EmailAudit.last).to have_attributes(message_type: 'can_order_in_fe_college',
                                                 template: Settings.govuk_notify.templates.devices.can_order_devices_in_fe_college,
                                                 user_id: user.id,
                                                 school_id: school.id,
                                                 email_address: user.email_address)
    end

    it 'enqueues mailer job with #deliver_later' do
      expect {
        described_class.with(user: user, school: school).user_can_order_in_fe_college.deliver_later
      }.to have_enqueued_job.on_queue('mailers')
    end

    it 'sends mail with #deliver_now' do
      expect {
        described_class.with(user: user, school: school).user_can_order_in_fe_college.deliver_now
      }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end

    context 'when user is deleted' do
      let(:user) { create(:school_user, deleted_at: 1.second.ago) }

      it 'enqueues mailer job with #deliver_later' do
        expect {
          described_class.with(user: user, school: school).user_can_order_in_fe_college.deliver_later
        }.to have_enqueued_job.on_queue('mailers')
      end

      it 'does not send mail with #deliver_now' do
        expect {
          described_class.with(user: user, school: school).user_can_order_in_fe_college.deliver_now
        }.not_to change(ActionMailer::Base.deliveries, :size)
      end
    end
  end

  describe '#user_can_order_in_virtual_cap' do
    it 'adds an email audit record' do
      expect {
        described_class.with(user: user, school: school).user_can_order_in_virtual_cap.deliver_now
      }.to change { EmailAudit.count }.by(1)
    end

    it 'sets the correct values on the email audit record' do
      described_class.with(user: user, school: school).user_can_order_in_virtual_cap.deliver_now
      expect(EmailAudit.last).to have_attributes(message_type: 'can_order_in_virtual_cap',
                                                 template: Settings.govuk_notify.templates.devices.can_order_devices_in_virtual_cap,
                                                 user_id: user.id,
                                                 school_id: school.id,
                                                 email_address: user.email_address)
    end

    it 'enqueues mailer job with #deliver_later' do
      expect {
        described_class.with(user: user, school: school).user_can_order_in_virtual_cap.deliver_later
      }.to have_enqueued_job.on_queue('mailers')
    end

    it 'sends mail with #deliver_now' do
      expect {
        described_class.with(user: user, school: school).user_can_order_in_virtual_cap.deliver_now
      }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end

    context 'when user is deleted' do
      let(:user) { create(:school_user, deleted_at: 1.second.ago) }

      it 'enqueues mailer job with #deliver_later' do
        expect {
          described_class.with(user: user, school: school).user_can_order_in_virtual_cap.deliver_later
        }.to have_enqueued_job.on_queue('mailers')
      end

      it 'does not send mail with #deliver_now' do
        expect {
          described_class.with(user: user, school: school).user_can_order_in_virtual_cap.deliver_now
        }.not_to change(ActionMailer::Base.deliveries, :size)
      end
    end
  end

  describe '#user_can_order_but_action_is_needed' do
    it 'adds an email audit record' do
      expect {
        described_class.with(user: user, school: school).user_can_order_but_action_needed.deliver_now
      }.to change { EmailAudit.count }.by(1)
    end

    it 'sets the correct values on the email audit record' do
      described_class.with(user: user, school: school).user_can_order_but_action_needed.deliver_now
      expect(EmailAudit.last).to have_attributes(message_type: 'can_order_but_action_needed',
                                                 template: Settings.govuk_notify.templates.devices.can_order_but_action_needed,
                                                 user_id: user.id,
                                                 school_id: school.id,
                                                 email_address: user.email_address)
    end
  end

  describe '#nudge_rb_to_add_school_contact' do
    it 'adds an email audit record' do
      expect {
        described_class.with(user: user, school: school).nudge_rb_to_add_school_contact.deliver_now
      }.to change { EmailAudit.count }.by(1)
    end

    it 'sets the correct values on the email audit record' do
      described_class.with(user: user, school: school).nudge_rb_to_add_school_contact.deliver_now
      expect(EmailAudit.last).to have_attributes(message_type: 'nudge_rb_to_add_school_contact',
                                                 template: Settings.govuk_notify.templates.devices.nudge_rb_to_add_school_contact,
                                                 user_id: user.id,
                                                 school_id: school.id,
                                                 email_address: user.email_address)
    end
  end
end
