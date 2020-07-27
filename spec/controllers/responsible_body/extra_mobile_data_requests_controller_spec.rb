require 'rails_helper'

RSpec.describe ResponsibleBody::ExtraMobileDataRequestsController, type: :controller do
  let(:local_authority_user) { create(:local_authority_user) }

  context 'when authenticated' do
    before do
      sign_in_as local_authority_user

      @vouchers = create_list(:bt_wifi_voucher, 2, responsible_body: local_authority_user.responsible_body)
    end

    describe 'create' do
      let(:sms_client) { instance_double('Notifications::Client') }
      let(:mno) { create(:mobile_network) }
      let(:form_attrs) { attributes_for(:extra_mobile_data_request, mobile_network_id: mno.id) }
      let(:request_data) { { extra_mobile_data_request: form_attrs, confirm: 'confirm' } }
      let(:service) { NotifyExtraMobileDataAccountHolderService.new }

      before do
        allow(sms_client).to receive(:send_sms)
        allow(service).to receive(:sms_client) { sms_client }
        controller.send(:instance_variable_set, '@sms_service', service)
      end

      it 'sends an sms to the account holder of the request' do
        post :create, params: request_data

        expect(sms_client).to have_received(:send_sms).with(
          {
            phone_number: form_attrs[:device_phone_number],
            template_id: Settings.govuk_notify.templates.extra_mobile_data_requests.mno_in_scheme_sms,
            personalisation: {
              mno: mno.brand,
            },
          },
        )
      end
    end
  end
end
