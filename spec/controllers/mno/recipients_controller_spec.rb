require 'rails_helper'

describe Mno::RecipientsController, type: :controller do
  let(:local_authority_user) { create(:local_authority_user) }
  let(:mno_user) { create(:mno_user) }
  let(:other_mno) { create(:mobile_network, brand: 'Other MNO') }
  let(:user_from_other_mno) { create(:mno_user, name: 'Other MNO-User', organisation: 'Other MNO', mobile_network: other_mno) }
  let!(:recipient_1_for_mno) { create(:recipient, account_holder_name: 'mno recipient', mobile_network: mno_user.mobile_network, created_by_user: local_authority_user) }
  let!(:recipient_2_for_mno) { create(:recipient, account_holder_name: 'mno recipient', mobile_network: mno_user.mobile_network, created_by_user: local_authority_user) }
  let!(:recipient_for_other_mno) { create(:recipient, account_holder_name: 'other mno recipient', mobile_network: other_mno, created_by_user: local_authority_user) }

  before do
    sign_in_as mno_user
  end

  describe 'PUT /bulk_update' do
    let(:valid_params) do
      {
        mno_recipients_form: {
          recipient_ids: recipients.pluck('id'),
          status: 'cancelled',
        },
      }
    end
    let(:recipient_statusses) { recipients.map { |r| r.reload.status } }

    context 'with recipient_ids from the same MNO as the user' do
      let(:recipients) { [recipient_1_for_mno, recipient_2_for_mno] }

      it 'updates all the recipients' do
        put :bulk_update, params: valid_params

        expect(recipient_1_for_mno.reload.status).to eq('cancelled')
        expect(recipient_2_for_mno.reload.status).to eq('cancelled')
      end

      it 'redirects_to recipients index' do
        put :bulk_update, params: valid_params
        expect(response).to redirect_to(mno_recipients_path)
      end
    end

    # Pentest issue, Trello card #202
    context 'with some recipient_ids from another MNO' do
      let(:recipients) { [recipient_1_for_mno, recipient_for_other_mno] }

      it 'updates the recipients from the same MNO as the user' do
        put :bulk_update, params: valid_params

        expect(recipient_1_for_mno.reload.status).to eq('cancelled')
      end

      it 'does not update the recipient from the other MNO' do
        put :bulk_update, params: valid_params

        expect(recipient_for_other_mno.reload.status).not_to eq('cancelled')
      end

      it 'redirects_to recipients index' do
        put :bulk_update, params: valid_params
        expect(response).to redirect_to(mno_recipients_path)
      end
    end

    context 'when the given status is not valid' do
      let(:recipients) { [recipient_1_for_mno, recipient_2_for_mno] }
      let(:params_with_invalid_status) do
        {
          mno_recipients_form: {
            recipient_ids: recipients.pluck('id'),
            status: 'not_a_real_status',
          },
        }
      end

      it 'does not update the statusses' do
        put :bulk_update, params: params_with_invalid_status
        expect(recipient_1_for_mno.reload.status).not_to eq('not_a_real_status')
        expect(recipient_2_for_mno.reload.status).not_to eq('not_a_real_status')
      end

      it 'responds with :unprocessable_entity' do
        put :bulk_update, params: params_with_invalid_status
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the given status is nil' do
      let(:recipients) { [recipient_1_for_mno, recipient_2_for_mno] }
      let(:params_with_invalid_status) do
        {
          mno_recipients_form: {
            recipient_ids: recipients.pluck('id'),
            status: nil,
          },
        }
      end

      it 'does not update the statusses' do
        put :bulk_update, params: params_with_invalid_status
        expect(recipient_1_for_mno.reload.status).not_to be_nil
        expect(recipient_2_for_mno.reload.status).not_to be_nil
      end

      it 'responds with :unprocessable_entity' do
        put :bulk_update, params: params_with_invalid_status
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
