require 'rails_helper'

RSpec.describe ExtraMobileDataRequest, type: :model do
  it { is_expected.to be_versioned }
  it { is_expected.to validate_presence_of(:mobile_network_id) }

  it 'fails validation when the network is missing' do
    request = build(:extra_mobile_data_request, mobile_network: nil)
    expect(request).not_to be_valid
  end

  describe 'to_csv' do
    let(:requests) { ExtraMobileDataRequest.all }

    context 'when account_holder_name starts with a =' do
      before { create(:extra_mobile_data_request, account_holder_name: '=(1+2)') }

      it 'prevents formula injection' do
        expect(requests.to_csv).to include(%q{"'=(1+2)"})
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

  describe 'validates device_phone_number is not the example number' do
    subject(:model) { described_class.new(device_phone_number: '07123456789') }

    it 'is not valid' do
      expect(model.valid?).to be_falsey
      expect(model.errors[:device_phone_number]).to be_present
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

  describe 'validate request uniqueness' do
    let(:school) { create(:school) }
    let(:rb) { create(:trust) }

    context 'when rb present' do
      let(:existing_request) do
        create(:extra_mobile_data_request, account_holder_name: 'Person', device_phone_number: '07123456788', responsible_body: rb)
      end

      subject(:model) { build(:extra_mobile_data_request, school: nil, responsible_body: existing_request.responsible_body) }

      it 'is invalid' do
        model.valid?
        expect(model.errors[:device_phone_number]).to be_blank

        model.account_holder_name = 'Person'
        model.valid?
        expect(model.errors[:device_phone_number]).to be_blank

        model.device_phone_number = '07123456788'
        model.valid?
        expect(model.errors[:device_phone_number]).to be_blank

        model.mobile_network_id = existing_request.mobile_network_id
        model.valid?
        expect(model.errors[:device_phone_number]).to include 'A request with these details has already been made'
      end
    end

    context 'when school present' do
      let(:existing_request) do
        create(:extra_mobile_data_request, account_holder_name: 'Person 2', device_phone_number: '07123456780', school: school)
      end

      subject(:model) { build(:extra_mobile_data_request, school: existing_request.school, responsible_body: nil) }

      it 'is invalid' do
        model.valid?
        expect(model.errors[:device_phone_number]).to be_blank

        model.account_holder_name = 'Person 2'
        model.valid?
        expect(model.errors[:device_phone_number]).to be_blank

        model.device_phone_number = '07123456780'
        model.valid?
        expect(model.errors[:device_phone_number]).to be_blank

        model.mobile_network_id = existing_request.mobile_network_id
        model.valid?
        expect(model.errors[:device_phone_number]).to include 'A request with these details has already been made'
      end
    end

    context 'when the device_phone_number is not normalised' do
      let(:existing_request) do
        create(:extra_mobile_data_request, account_holder_name: 'Person 2', device_phone_number: '07123456780', school: school)
      end

      subject(:model) { build(:extra_mobile_data_request, school: existing_request.school, mobile_network_id: existing_request.mobile_network_id, account_holder_name: existing_request.account_holder_name, responsible_body: nil, device_phone_number: '07123 456 780') }

      before do
        model.mobile_network_id = existing_request.mobile_network_id
      end

      it 'is invalid' do
        expect(model.valid?).to be_falsey
      end

      it 'detects the existing record with the normalised phone number' do
        model.valid?
        expect(model.errors[:device_phone_number]).to include 'A request with these details has already been made'
      end
    end

    context 'when the account_holder_name is different but the normalised name exists' do
      let(:existing_request) do
        create(:extra_mobile_data_request, account_holder_name: 'Person 2', device_phone_number: '07123456780', school: school)
      end

      subject(:model) { existing_request.dup }

      before do
        model.account_holder_name = ' person  2'
      end

      it 'is invalid' do
        expect(model.valid?).to be_falsey
      end

      it 'detects the existing record with the normalised name' do
        model.valid?
        expect(model.errors[:device_phone_number]).to include 'A request with these details has already been made'
      end
    end

    context 'when there is an existing request with everything the same except contract_type' do
      let(:existing_request) do
        create(:extra_mobile_data_request, account_holder_name: 'Person', device_phone_number: '07123456788', responsible_body: rb, contract_type: 'pay_as_you_go_payg')
      end

      subject(:model) do
        build(:extra_mobile_data_request, device_phone_number: existing_request.device_phone_number,
                                          account_holder_name: existing_request.account_holder_name,
                                          mobile_network_id: existing_request.mobile_network_id,
                                          responsible_body: existing_request.responsible_body,
                                          contract_type: 'pay_monthly')
      end

      it 'is valid' do
        expect(model.valid?).to be_truthy
      end
    end
  end

  describe 'validating device_phone_number' do
    it { is_expected.to validate_presence_of(:device_phone_number) }

    context 'for a mobile phone number starting with 07' do
      it { is_expected.to allow_value('077  125 92368').for(:device_phone_number) }
    end

    context 'for a landline phone number' do
      it { is_expected.not_to allow_value('0123456789').for(:device_phone_number) }
    end

    context 'for non-UK numbers' do
      it { is_expected.not_to allow_value('+49 1521 5678901').for(:device_phone_number) }
    end

    it 'skips validation when updating the record for an already invalid number' do
      request = build(:extra_mobile_data_request, device_phone_number: '12345')
        .tap { |record| record.save!(validate: false) }

      expect(request.update(status: :complete)).to be_truthy
    end
  end

  def mno_request_for_number(device_phone_number)
    FactoryBot.create(:extra_mobile_data_request, device_phone_number: device_phone_number)
  end

  it 'normalises phone numbers to the national format without spaces' do
    expect(mno_request_for_number('07 123 456 780').device_phone_number).to eq('07123456780')
    expect(mno_request_for_number('0712345 6780').device_phone_number).to eq('07123456780')
    expect(mno_request_for_number('+44 7712345678').device_phone_number).to eq('07712345678')
  end

  it 'normalises phone numbers without the leading zero to the national format without spaces' do
    expect(mno_request_for_number('7123456780').device_phone_number).to eq('07123456780')
  end

  describe 'normalising account_holder_name' do
    subject(:request) { described_class.new(account_holder_name: account_holder_name) }

    before do
      request.normalise_name
    end

    context 'given a name with spaces' do
      let(:account_holder_name) { '  A NNA P urna ' }

      it 'removes all the spaces' do
        expect(request.normalised_name).to eq('annapurna')
      end
    end

    context 'given an account_holder_name with mixed case' do
      let(:account_holder_name) { 'ANNA NG' }

      it 'normalises to all lower case' do
        expect(request.normalised_name).to eq('annang')
      end
    end

    context 'given a name with punctuation' do
      let(:account_holder_name) { 'Mr. Miles Cholmondley-Warner Esq.' }

      it 'removes all the spaces' do
        expect(request.normalised_name).to eq('mrmilescholmondleywarneresq')
      end
    end

    context 'given a name with non-ASCII characters' do
      let(:account_holder_name) { 'MĀREK Buzkēvičš' }

      it 'retains and correctly downcases all non-ASCII characters' do
        expect(request.normalised_name).to eq('mārekbuzkēvičš')
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

  describe 'updating the hashable fields' do
    subject(:req) { create(:extra_mobile_data_request, account_holder_name: 'old name', device_phone_number: '07777111222') }

    describe 'updating the account_holder_name' do
      it 'updates the hashed_account_holder_name' do
        expect { req.update!(account_holder_name: 'some new value') }.to change(req, :hashed_account_holder_name).to(Digest::MD5.hexdigest('some new value'))
      end

      it 'updates the hashed_normalised_name' do
        expect { req.update!(account_holder_name: 'Some New Value') }.to change(req, :hashed_normalised_name).to(Digest::MD5.hexdigest('somenewvalue'))
      end
    end

    describe 'updating the device_phone_number' do
      it 'updates the hashed_device_phone_number' do
        expect { req.update!(device_phone_number: '07777888999') }.to change(req, :hashed_device_phone_number).to(Digest::MD5.hexdigest('07777888999'))
      end

      context 'when device_phone_number is nil' do
        it 'updates the hashed_device_phone_number to nil' do
          expect { req.update!(device_phone_number: nil) }.to change(req, :hashed_device_phone_number).to(nil)
        end
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

      it 'does not change the status from new' do
        request.save_and_notify_account_holder!
        expect(request.new_status?).to be true
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
        expect(request.unavailable_status?).to be true
      end

      it 'enqueues a job to message the account holder' do
        expect {
          request.save_and_notify_account_holder!
        }.to have_enqueued_job(NotifyExtraMobileDataRequestAccountHolderJob)
      end
    end
  end

  context 'updating a request' do
    let(:reportable_event) { ReportableEvent.last }

    context 'that is not already complete' do
      let(:request) { create(:extra_mobile_data_request, status: 'in_progress') }

      context 'to complete' do
        let(:updating_the_request) { request.update!(status: 'complete') }

        it 'adds a ReportableEvent with the correct parameters' do
          expect { updating_the_request }.to change(ReportableEvent, :count).by(1)
          expect(reportable_event).to have_attributes(event_name: 'completion', record_type: 'ExtraMobileDataRequest', record_id: request.id)
          expect(reportable_event.event_time).to be_within(1.second).of(Time.zone.now.utc)
        end
      end

      context 'to a status which is not complete' do
        let(:updating_the_request) { request.update!(status: 'problem_other') }

        it 'does not add a ReportableEvent' do
          expect { updating_the_request }.not_to change(ReportableEvent, :count)
        end
      end
    end

    context 'that is already complete' do
      let(:request) { create(:extra_mobile_data_request, status: 'complete') }

      context 'without changing the status from complete' do
        let(:updating_the_request) { request.update!(status: 'complete', account_holder_name: request.account_holder_name + '_') }

        it 'does not add a ReportableEvent' do
          request
          expect { updating_the_request }.not_to change(ReportableEvent, :count)
        end
      end
    end
  end

  context 'saving a new request' do
    let(:reportable_event) { ReportableEvent.last }

    context 'that is complete' do
      let(:saving_the_request) { create(:extra_mobile_data_request, status: 'complete') }

      it 'adds a ReportableEvent with the correct parameters' do
        expect { saving_the_request }.to change(ReportableEvent, :count).by(1)
        expect(reportable_event).to have_attributes(event_name: 'completion', record_type: 'ExtraMobileDataRequest', record_id: saving_the_request.id)
        expect(reportable_event.event_time).to be_within(1.second).of(Time.zone.now.utc)
      end
    end

    context 'that is not complete' do
      let(:saving_the_request) { create(:extra_mobile_data_request, status: 'new') }

      it 'does not add a ReportableEvent' do
        expect { saving_the_request }.not_to change(ReportableEvent, :count)
      end
    end
  end
end
