require 'rails_helper'

RSpec.describe NotifySmsMessage, type: :model do
  let(:request) { create(:extra_mobile_data_request) }
  let(:message) do
    described_class.new(
      phone_number: request.device_phone_number,
      template_id: Settings.govuk_notify.templates.extra_mobile_data_requests.mno_in_scheme_sms,
      personalisation: {
        mno: request.mobile_network.brand,
      },
    )
  end
  let(:sms_client) { instance_double('Notifications::Client') }

  describe '#deliver!' do
    before do
      allow(sms_client).to receive(:send_sms)
      message.send(:instance_variable_set, :@sms_client, sms_client)
    end

    it 'sends a SMS message' do
      message.deliver!
      expect(sms_client).to have_received(:send_sms).once
    end

    context 'when the Notify client raises an error' do
      before do
        err = instance_double('Net::HTTPClientError')
        allow(err).to receive(:code).and_return(400)
        allow(err).to receive(:body).and_return('boom')

        message.send(:instance_variable_set, :@sms_client, sms_client)
        allow(sms_client).to receive(:send_sms).and_raise(Notifications::Client::RequestError, err)
      end

      it 'catches the error and raises a NotifySmsError' do
        expect { message.deliver! }.to raise_error(NotifySmsMessage::NotifySmsError)
      end
    end
  end
end
