require 'rails_helper'

RSpec.describe NotifyExtraMobileDataAccountHolderService, type: :model do
  context 'for a mno that is providing extra data' do
    let(:request) { create(:extra_mobile_data_request) }
    let(:sms_client) { double('sms_client') }

    subject { described_class.new(request) }

    before do
      allow(subject).to receive(:sms_client) { sms_client }
    end

    it 'sends the extra data offer sms message' do
      expect(sms_client).to receive(:send_sms).with(
        {
          phone_number: request.device_phone_number,
          template_id: Settings.govuk_notify.templates.extra_mobile_data_requests.mno_in_scheme_sms,
          personalisation: {
            mno: request.mobile_network.brand,
          },
        },
      )
      subject.call
    end
  end

  context 'for a mno that has not signed up' do
    let(:request) { create(:extra_mobile_data_request, :mno_not_participating) }
    let(:sms_client) { double('sms_client') }

    subject { described_class.new(request) }

    before do
      allow(subject).to receive(:sms_client) { sms_client }
    end

    it 'sends the mno not providing data sms message' do
      expect(sms_client).to receive(:send_sms).with(
        {
          phone_number: request.device_phone_number,
          template_id: Settings.govuk_notify.templates.extra_mobile_data_requests.mno_not_in_scheme_sms,
          personalisation: {
            mno: request.mobile_network.brand,
          },
        },
      )
      subject.call
    end
  end

  context 'an error with Notify' do
    let(:request) { create(:extra_mobile_data_request) }
    let(:sms_client) { double('sms_client') }

    subject { described_class.new(request) }

    before do
      err = double('error')
      allow(err).to receive(:code).and_return(400)
      allow(err).to receive(:body).and_return('boom')

      allow(subject).to receive(:sms_client) { sms_client }
      allow(sms_client).to receive(:send_sms).and_raise(Notifications::Client::RequestError, err)
    end

    it 'catches the error and raises a NotifySmsError' do
      expect { subject.call }.to raise_error(NotifyExtraMobileDataAccountHolderService::NotifySmsError)
    end
  end
end
