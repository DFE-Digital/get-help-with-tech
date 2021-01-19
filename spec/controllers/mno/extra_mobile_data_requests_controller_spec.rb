require 'rails_helper'

describe Mno::ExtraMobileDataRequestsController, type: :controller do
  let(:local_authority_user) { create(:local_authority_user) }
  let(:mno_user) { create(:mno_user) }
  let(:other_mno) { create(:mobile_network, brand: 'Other MNO') }
  let(:user_from_other_mno) { create(:mno_user, name: 'Other MNO-User', mobile_network: other_mno) }
  let!(:extra_mobile_data_request_1_for_mno) { create(:extra_mobile_data_request, account_holder_name: 'mno extra_mobile_data_request', mobile_network: mno_user.mobile_network, created_by_user: local_authority_user) }
  let!(:extra_mobile_data_request_2_for_mno) { create(:extra_mobile_data_request, account_holder_name: 'mno extra_mobile_data_request', mobile_network: mno_user.mobile_network, created_by_user: local_authority_user) }
  let!(:extra_mobile_data_request_for_other_mno) { create(:extra_mobile_data_request, account_holder_name: 'other mno extra_mobile_data_request', mobile_network: other_mno, created_by_user: local_authority_user) }

  before do
    sign_in_as mno_user
  end

  describe 'GET index' do
    it 'does not "cancelled" and "unavailable" as possible statuses to transition a request into' do
      get :index

      expect(assigns(:statuses).map(&:value)).to contain_exactly(
        'requested',
        'in_progress',
        'complete',
        'problem_no_longer_on_network',
        'problem_incorrect_phone_number',
        'problem_no_match_for_account_name',
        'problem_no_match_for_number',
        'problem_not_eligible',
      )
    end
  end

  describe 'PATCH update' do
    let(:params) do
      {
        id: extra_mobile_data_request_1_for_mno.id,
        extra_mobile_data_request: {
          status: 'problem_no_match_for_number',
        },
      }
    end

    context 'for a request from an approved user' do
      it 'updates the status' do
        patch :update, params: params
        expect(extra_mobile_data_request_1_for_mno.reload.status).to eq('problem_no_match_for_number')
      end
    end
  end

  describe 'PUT /bulk_update' do
    let(:valid_params) do
      {
        mno_extra_mobile_data_requests_form: {
          extra_mobile_data_request_ids: extra_mobile_data_requests.pluck('id'),
          status: 'cancelled',
        },
      }
    end
    let(:extra_mobile_data_request_statusses) { extra_mobile_data_requests.map { |r| r.reload.status } }

    context 'when no requests are selected' do
      let(:params) do
        {
          mno_extra_mobile_data_requests_form: {
            status: 'cancelled',
          },
        }
      end

      it 'does not throw an error' do
        expect {
          put :bulk_update, params: params
        }.not_to raise_error
      end
    end

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
end
