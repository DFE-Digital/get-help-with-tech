require 'rails_helper'

RSpec.describe LogEmailDeliveryObserver do
  let(:message) do
    Mail.new do
      from    'sender@example.com'
      to      'recipient@example.com'
      subject 'This is a test email'
      body    'hello world'
    end
  end

  let(:delivery_method) { OpenStruct.new(response:) }
  let(:response) { OpenStruct.new(reference: audit.id, id: '456') }
  let(:audit) { create(:email_audit) }

  before do
    allow(message).to receive(:delivery_method).and_return(delivery_method)
    allow(delivery_method).to receive(:is_a?).with(Mail::Notify::DeliveryMethod).and_return(true)
  end

  describe '::delivered_email' do
    let(:logger) { instance_double(Rails.logger.class, debug: nil) }

    before do
      audit
    end

    it 'logs email sent a debugger level' do
      allow(Rails).to receive(:logger).and_return(logger)
      described_class.delivered_email(message)
      expect(logger).to have_received(:debug)
    end

    it 'links message with audit' do
      described_class.delivered_email(message)
      audit.reload
      expect(audit.govuk_notify_id).to eql('456')
    end
  end
end
