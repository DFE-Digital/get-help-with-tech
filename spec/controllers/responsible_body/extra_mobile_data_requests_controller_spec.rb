require 'rails_helper'

RSpec.describe ResponsibleBody::ExtraMobileDataRequestsController, type: :controller do
  let(:local_authority_user) { create(:local_authority_user) }

  context 'when authenticated' do
    before do
      sign_in_as local_authority_user

      @vouchers = create_list(:bt_wifi_voucher, 2, responsible_body: local_authority_user.responsible_body)
    end

    describe 'create' do
      let(:sms_client) { double('sms_client') }
      let(:mno) { create(:mobile_network) }
      let(:form_attrs) { attributes_for(:extra_mobile_data_request, mobile_network_id: mno.id) }

      before do
        allow_any_instance_of(NotifyExtraMobileDataAccountHolderService).to receive(:sms_client).and_return(sms_client)
      end

      it 'sends an sms to the account holder of the request' do
        request_data = {
          extra_mobile_data_request: form_attrs,
          confirm: 'confirm',
        }

        expect(sms_client).to receive(:send_sms).with(
          {
            phone_number: form_attrs[:device_phone_number],
            template_id: Settings.govuk_notify.templates.extra_mobile_data_requests.mno_in_scheme_sms,
            personalisation: {
              mno: mno.brand,
            },
          },
        )
        post :create, params: request_data
      end
    end
  end
end
