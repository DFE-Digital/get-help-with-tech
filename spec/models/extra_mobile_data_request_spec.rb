require 'rails_helper'

RSpec.describe ExtraMobileDataRequest, type: :model do
  describe '.from_approved_users' do
    let(:approved_user) { create(:local_authority_user, :approved) }
    let(:not_approved_user) { create(:local_authority_user, :not_approved) }

    it 'includes entries from approved users only' do
      extra_mobile_data_request_from_approved_user = create(:extra_mobile_data_request, created_by_user: approved_user)
      create(:extra_mobile_data_request, created_by_user: not_approved_user)

      expect(ExtraMobileDataRequest.from_approved_users).to eq([extra_mobile_data_request_from_approved_user])
    end
  end

  describe 'to_csv' do
    let(:requests) { ExtraMobileDataRequest.all }

    context 'when account_holder_name starts with a =' do
      before { create(:extra_mobile_data_request, account_holder_name: '=(1+2)') }

      it 'prepends the = with a .' do
        expect(requests.to_csv).to include('.=(1+2)')
      end
    end

    context 'when account_holder_name does not start with a =' do
      before { create(:extra_mobile_data_request, account_holder_name: 'Ben Benson') }

      it 'does not prepend the account_holder_name with a .' do
        expect(requests.to_csv).to include('Ben Benson')
        expect(requests.to_csv).not_to include('.Ben Benson')
      end
    end
  end
end
