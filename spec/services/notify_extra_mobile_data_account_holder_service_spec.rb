require 'rails_helper'

RSpec.describe NotifyExtraMobileDataAccountHolderService, type: :model do
  context 'for a mno that is providing extra data' do
    let(:request) { create(:extra_mobile_data_request) }
    let(:sms_client) { instance_double('Notifications::Client') }
    let(:service) { described_class.new(request) }

    before do
      allow(service).to receive(:sms_client) { sms_client }
      allow(sms_client).to receive(:send_sms)
    end

    it 'sends the extra data offer sms message' do
      service.call
      expect(sms_client).to have_received(:send_sms).with(
        {
          phone_number: request.device_phone_number,
          template_id: Settings.govuk_notify.templates.extra_mobile_data_requests.mno_in_scheme_sms,
          personalisation: {
            mno: request.mobile_network.brand,
          },
        },
      )
    end
  end

  context 'for a mno that has not signed up' do
    let(:request) { create(:extra_mobile_data_request, :mno_not_participating) }
    let(:service) { described_class.new(request) }
    let(:sms_client) { instance_double('Notifications::Client') }

    before do
      allow(service).to receive(:sms_client) { sms_client }
      allow(sms_client).to receive(:send_sms)
    end

    it 'sends the mno not providing data sms message' do
      service.call
      expect(sms_client).to have_received(:send_sms).with(
        {
          phone_number: request.device_phone_number,
          template_id: Settings.govuk_notify.templates.extra_mobile_data_requests.mno_not_in_scheme_sms,
          personalisation: {
            mno: request.mobile_network.brand,
          },
        },
      )
    end
  end

  context 'when the Notify client raises an error' do
    let(:request) { create(:extra_mobile_data_request) }
    let(:service) { described_class.new(request) }
    let(:sms_client) { instance_double('Notifications::Client') }

    before do
      err = instance_double('Net::HTTPClientError')
      allow(err).to receive(:code).and_return(400)
      allow(err).to receive(:body).and_return('boom')

      allow(service).to receive(:sms_client) { sms_client }
      allow(sms_client).to receive(:send_sms).and_raise(Notifications::Client::RequestError, err)
    end

    it 'catches the error and raises a NotifySmsError' do
      expect { service.call }.to raise_error(NotifyExtraMobileDataAccountHolderService::NotifySmsError)
    end
  end
end
