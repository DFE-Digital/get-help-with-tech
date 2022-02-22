require 'rails_helper'

RSpec.describe MnoMailer, type: :mailer do
  let(:user) { build(:mno_user) }

  describe '#notify_new_requests' do
    subject(:mail) { MnoMailer.notify_new_requests(user:, number_of_new_requests: 3) }

    it 'sends to user with correct personalisation' do
      expect(mail.to).to eq([user.email_address])

      expected_personalisation = {
        full_name: user.full_name,
        brand: user.mobile_network.brand,
        number: 3,
      }

      expect(mail[:personalisation].unparsed_value).to eq(expected_personalisation)
    end

    it 'audits the email' do
      expect { mail.deliver_now }.to change(EmailAudit, :count).by(1)

      audit = EmailAudit.last
      expect(audit.message_type).to eql('notify_new_requests')
      expect(audit.template).to eql(Settings.govuk_notify.templates.mno.notify_new_requests)
      expect(audit.email_address).to eql(user.email_address)
      expect(audit.user).to eql(user)
    end
  end
end
