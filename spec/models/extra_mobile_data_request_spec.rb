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

  describe 'validate RB or school must be present' do
    let(:school) { create(:school) }
    let(:rb) { create(:trust) }

    context 'when rb and school present' do
      subject(:model) { described_class.new(responsible_body: rb, school: school) }

      it 'is valid' do
        model.valid?
        expect(model.errors[:school]).to be_blank
        expect(model.errors[:responsible_body]).to be_blank
      end
    end

    context 'when responsible body present' do
      subject(:model) { described_class.new(responsible_body: rb) }

      it 'is valid with rb present' do
        model.valid?
        expect(model.errors[:school]).to be_blank
        expect(model.errors[:responsible_body]).to be_blank
      end
    end

    context 'when school present' do
      subject(:model) { described_class.new(responsible_body: rb) }

      it 'is valid with school present' do
        model.valid?
        expect(model.errors[:school]).to be_blank
        expect(model.errors[:responsible_body]).to be_blank
      end
    end

    context 'when neither rb or school present' do
      subject(:model) { described_class.new }

      it 'is not valid' do
        model.valid?
        expect(model.errors[:school]).to be_present
        expect(model.errors[:responsible_body]).to be_present
      end
    end
  end

  describe 'validating device_phone_number' do
    context 'a phone number that starts with 07' do
      let(:request) { subject }

      before do
        request.device_phone_number = '077  125 92368'
      end

      it 'is valid' do
        request.valid?
        expect(request.errors).not_to(have_key(:device_phone_number))
      end
    end

    context 'a phone number that does not start with 07' do
      let(:request) { subject }

      before do
        request.device_phone_number = '=077  125 92368'
      end

      it 'is not valid' do
        request.valid?
        expect(request.errors).to(have_key(:device_phone_number))
      end
    end
  end

  describe 'validating contract_type' do
    context 'when a new record' do
      let(:request) { subject }

      it 'is valid with a contract_type' do
        request.contract_type = :pay_as_you_go_payg
        request.valid?
        expect(request.errors).not_to have_key(:contract_type)
      end

      it 'is not valid without a contract_type' do
        request.valid?
        expect(request.errors).to have_key(:contract_type)
      end
    end

    context 'when an existing record' do
      let(:request) { create(:extra_mobile_data_request) }

      it 'is valid without a contract_type' do
        request.contract_type = nil
        expect(request.valid?).to be true
      end
    end
  end

  describe '#notify_account_holder_later' do
    let(:rb) { create(:trust) }
    let(:request) { build(:extra_mobile_data_request, responsible_body: rb, mobile_network: create(:mobile_network)) }

    it 'enqueues a job to send the message' do
      expect {
        request.save_and_notify_account_holder!
      }.to have_enqueued_job(NotifyExtraMobileDataRequestAccountHolderJob)
      expect(request).to be_persisted
    end
  end

  describe '#notify_account_holder_now' do
    context 'for a mno that is providing extra data' do
      let(:request) { create(:extra_mobile_data_request) }
      let(:notification) { instance_double('ExtraMobileDataRequestAccountHolderNotification') }

      before do
        request.send(:instance_variable_set, :@notification, notification)
        allow(notification).to receive(:deliver_now)
      end

      it 'sends the extra data offer sms message' do
        request.notify_account_holder_now
        expect(notification).to have_received(:deliver_now).once
      end
    end
  end

  describe '#save_and_notify_account_holder!' do
    context 'when mno is participating' do
      let(:request) { create(:extra_mobile_data_request) }

      it 'saves the request' do
        expect {
          request.save_and_notify_account_holder!
        }.to change { ExtraMobileDataRequest.count }.by(1)
      end

      it 'does not change the status from requested' do
        request.save_and_notify_account_holder!
        expect(request.requested?).to be true
      end

      it 'enqueues a job to message the account holder' do
        expect {
          request.save_and_notify_account_holder!
        }.to have_enqueued_job(NotifyExtraMobileDataRequestAccountHolderJob)
      end
    end

    context 'when mno is not participating' do
      let(:network) { create(:mobile_network, :maybe_participating_in_pilot) }
      let(:request) { create(:extra_mobile_data_request, mobile_network_id: network.id) }

      it 'saves the request' do
        expect {
          request.save_and_notify_account_holder!
        }.to change { ExtraMobileDataRequest.count }.by(1)
      end

      it 'changes the status to unavailable' do
        request.save_and_notify_account_holder!
        expect(request.unavailable?).to be true
      end

      it 'enqueues a job to message the account holder' do
        expect {
          request.save_and_notify_account_holder!
        }.to have_enqueued_job(NotifyExtraMobileDataRequestAccountHolderJob)
      end
    end
  end
end
