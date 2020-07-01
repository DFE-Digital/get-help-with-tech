require 'rails_helper'

RSpec.describe Recipient, type: :model do
  describe '.from_approved_users' do
    let(:approved_user) { create(:local_authority_user, :approved) }
    let(:not_approved_user) { create(:local_authority_user, :not_approved) }

    it 'includes entries from approved users only' do
      recipient_from_approved_user = create(:recipient, created_by_user: approved_user)
      create(:recipient, created_by_user: not_approved_user)

      expect(Recipient.from_approved_users).to eq([recipient_from_approved_user])
    end
  end

  describe 'to_csv' do
    let(:recipients) { Recipient.all }

    context 'when account_holder_name starts with a =' do
      before { create(:recipient, account_holder_name: '=(1+2)') }

      it 'prepends the = with a .' do
        expect(recipients.to_csv).to include('.=(1+2)')
      end
    end

    context 'when account_holder_name does not start with a =' do
      before { create(:recipient, account_holder_name: 'Ben Benson') }

      it 'does not prepend the account_holder_name with a .' do
        expect(recipients.to_csv).to include('Ben Benson')
        expect(recipients.to_csv).not_to include('.Ben Benson')
      end
    end

    context 'when device_phone_number starts with a =' do
      before { create(:recipient, device_phone_number: '=(1+2)') }

      it 'prepends the = with a .' do
        expect(recipients.to_csv).to include('.=(1+2)')
      end
    end

    context 'when device_phone_number does not start with a =' do
      before { create(:recipient, account_holder_name: '07123456789') }

      it 'does not prepend the device_phone_number with a .' do
        expect(recipients.to_csv).to include('07123456789')
        expect(recipients.to_csv).not_to include('.07123456789')
      end
    end
  end
end
