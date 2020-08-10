require 'rails_helper'

RSpec.describe ExtraMobileDataRequestAccountHolderNotification, type: :model do
  let(:request) { create(:extra_mobile_data_request) }
  let(:service) { described_class.new(request) }

  describe '#deliver_now' do
    let(:message) { instance_double(NotifySmsMessage) }

    before do
      allow(message).to receive(:deliver!)
      service.send(:instance_variable_set, :@message, message)
    end

    it 'sends a notify message to the account holder' do
      service.deliver_now
      expect(message).to have_received(:deliver!).once
    end

    context 'for a mno that is providing extra data' do
      let(:message) { service.send(:build_message) }

      it 'uses the account holders phone number' do
        expect(message.phone_number).to eq(request.device_phone_number)
      end

      it 'uses the extra data offer sms message' do
        expect(message.template_id).to eq(Settings.govuk_notify.templates.extra_mobile_data_requests.mno_in_scheme_sms)
      end
    end

    context 'for a mno that has not signed up' do
      let(:request) { create(:extra_mobile_data_request, :mno_not_participating) }
      let(:service) { described_class.new(request) }
      let(:message) { service.send(:build_message) }

      it 'uses the account holders phone number' do
        expect(message.phone_number).to eq(request.device_phone_number)
      end

      it 'uses the mno not providing data sms message' do
        expect(message.template_id).to eq(Settings.govuk_notify.templates.extra_mobile_data_requests.mno_not_in_scheme_sms)
      end
    end
  end

  describe '#deliver_later' do
    it 'enqueues a job to deliver the message in the background' do
      expect {
        service.deliver_later
      }.to have_enqueued_job(NotifyExtraMobileDataRequestAccountHolderJob).once
    end
  end
end
