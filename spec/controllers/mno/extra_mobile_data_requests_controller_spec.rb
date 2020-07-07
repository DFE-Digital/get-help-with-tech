require 'rails_helper'

describe Mno::ExtraMobileDataRequestsController, type: :controller do
  let(:local_authority_user) { create(:local_authority_user) }
  let(:mno_user) { create(:mno_user) }
  let(:other_mno) { create(:mobile_network, brand: 'Other MNO') }
  let(:user_from_other_mno) { create(:mno_user, name: 'Other MNO-User', organisation: 'Other MNO', mobile_network: other_mno) }
  let!(:extra_mobile_data_request_1_for_mno) { create(:extra_mobile_data_request, account_holder_name: 'mno extra_mobile_data_request', mobile_network: mno_user.mobile_network, created_by_user: local_authority_user) }
  let!(:extra_mobile_data_request_2_for_mno) { create(:extra_mobile_data_request, account_holder_name: 'mno extra_mobile_data_request', mobile_network: mno_user.mobile_network, created_by_user: local_authority_user) }
  let!(:extra_mobile_data_request_for_other_mno) { create(:extra_mobile_data_request, account_holder_name: 'other mno extra_mobile_data_request', mobile_network: other_mno, created_by_user: local_authority_user) }


  describe 'PUT /bulk_update' do
    before do
      sign_in_as mno_user
    end

    let(:valid_params) do
      {
        mno_extra_mobile_data_requests_form: {
          extra_mobile_data_request_ids: extra_mobile_data_requests.pluck('id'),
          status: 'cancelled',
        },
      }
    end
    let(:extra_mobile_data_request_statusses) { extra_mobile_data_requests.map { |r| r.reload.status } }

    context 'with extra_mobile_data_request_ids from the same MNO as the user' do
      let(:extra_mobile_data_requests) { [extra_mobile_data_request_1_for_mno, extra_mobile_data_request_2_for_mno] }

      it 'updates all the extra_mobile_data_requests' do
        put :bulk_update, params: valid_params

        expect(extra_mobile_data_request_1_for_mno.reload.status).to eq('cancelled')
        expect(extra_mobile_data_request_2_for_mno.reload.status).to eq('cancelled')
      end

      it 'redirects_to extra_mobile_data_requests index' do
        put :bulk_update, params: valid_params
        expect(response).to redirect_to(mno_extra_mobile_data_requests_path)
      end
    end

    # Pentest issue, Trello card #202
    context 'with some extra_mobile_data_request_ids from another MNO' do
      let(:extra_mobile_data_requests) { [extra_mobile_data_request_1_for_mno, extra_mobile_data_request_for_other_mno] }

      it 'updates the extra_mobile_data_requests from the same MNO as the user' do
        put :bulk_update, params: valid_params

        expect(extra_mobile_data_request_1_for_mno.reload.status).to eq('cancelled')
      end

      it 'does not update the extra_mobile_data_request from the other MNO' do
        put :bulk_update, params: valid_params

        expect(extra_mobile_data_request_for_other_mno.reload.status).not_to eq('cancelled')
      end

      it 'redirects_to extra_mobile_data_requests index' do
        put :bulk_update, params: valid_params
        expect(response).to redirect_to(mno_extra_mobile_data_requests_path)
      end
    end

    context 'when the given status is not valid' do
      let(:extra_mobile_data_requests) { [extra_mobile_data_request_1_for_mno, extra_mobile_data_request_2_for_mno] }
      let(:params_with_invalid_status) do
        {
          mno_extra_mobile_data_requests_form: {
            extra_mobile_data_request_ids: extra_mobile_data_requests.pluck('id'),
            status: 'not_a_real_status',
          },
        }
      end

      it 'does not update the statusses' do
        put :bulk_update, params: params_with_invalid_status
        expect(extra_mobile_data_request_1_for_mno.reload.status).not_to eq('not_a_real_status')
        expect(extra_mobile_data_request_2_for_mno.reload.status).not_to eq('not_a_real_status')
      end

      it 'responds with :unprocessable_entity' do
        put :bulk_update, params: params_with_invalid_status
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the given status is nil' do
      let(:extra_mobile_data_requests) { [extra_mobile_data_request_1_for_mno, extra_mobile_data_request_2_for_mno] }
      let(:params_with_invalid_status) do
        {
          mno_extra_mobile_data_requests_form: {
            extra_mobile_data_request_ids: extra_mobile_data_requests.pluck('id'),
            status: nil,
          },
        }
      end

      it 'does not update the statusses' do
        put :bulk_update, params: params_with_invalid_status
        expect(extra_mobile_data_request_1_for_mno.reload.status).not_to be_nil
        expect(extra_mobile_data_request_2_for_mno.reload.status).not_to be_nil
      end

      it 'responds with :unprocessable_entity' do
        put :bulk_update, params: params_with_invalid_status
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context 'not signed in' do
    describe 'GET #index' do
      it 'redirects to sign_in' do
        get :index
        expect(response).to redirect_to(sign_in_path)
      end

      # Pentest issue: Host Header Poisoning vulnerability
      context 'with a Host header that is Settings.hostname_for_urls' do
        it 'redirects to the host' do
          request.headers['HOST'] = Settings.hostname_for_urls
          get :index
          expect(response.headers['Location']).to include(Settings.hostname_for_urls)
        end
      end

      context 'with a Host header that is not Settings.hostname_for_urls' do
        it 'does not redirect to the malicious host' do
          request.headers['HOST'] = 'malicious.example.com'
          get :index
          expect(response.headers['Location']).not_to include('malicious.example.com')
        end
      end

      context 'with a X-Forwarded-Host header that is Settings.hostname_for_urls' do
        it 'redirects to the X-Forwarded-Host' do
          request.headers['X-Forwarded-Host'] = Settings.hostname_for_urls
          get :index
          expect(response.headers['Location']).to include(Settings.hostname_for_urls)
        end
      end

      context 'with a X-Forwarded-Host header that is not Settings.hostname_for_urls' do
        it 'does not redirect to the malicious X-Forwarded-Host' do
          request.headers['X-Forwarded-Host'] = 'malicious.example.com'
          get :index
          expect(response.headers['Location']).not_to include('malicious.example.com')
        end
      end
    end
  end
end
