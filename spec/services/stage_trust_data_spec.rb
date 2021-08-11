require 'rails_helper'

RSpec.describe StageTrustData, type: :model do
  describe 'importing trusts' do
    let(:filename) { Rails.root.join('tmp/trust_test_data.csv') }

    context 'when a trust does not already exist' do
      let(:attrs) do
        {
          gias_group_uid: '4001',
          companies_house_number: '09933123',
          name: 'Callio Forsythe Academy',
          address_1: 'Big Academy',
          address_2: 'Strange Lane',
          town: 'Easttown',
          postcode: 'EW1 1AA',
          status: 'Closed',
          organisation_type: 'Single-academy trust',
        }
      end

      before do
        create_trust_csv_file(filename, [attrs])
        @service = described_class.new(TrustDataFile.new(filename))
      end

      after do
        remove_file(filename)
      end

      it 'creates a new trust record' do
        expect {
          @service.import_trusts
        }.to change { DataStage::Trust.count }.by(1)
      end

      it 'sets the correct values on the Trust record' do
        @service.import_trusts
        expect(DataStage::Trust.last).to have_attributes(
          gias_group_uid: '4001',
          companies_house_number: '09933123',
          name: 'Callio Forsythe Academy',
          address_1: 'Big Academy',
          address_2: 'Strange Lane',
          town: 'Easttown',
          postcode: 'EW1 1AA',
          status: 'closed',
          organisation_type: 'single_academy_trust',
        )
      end
    end

    context 'when a trust already exists' do
      let!(:trust) { create(:staged_trust, companies_house_number: '09933123') }

      let(:attrs) do
        {
          gias_group_uid: '4001',
          companies_house_number: '09933123',
          name: 'Academy of Wigtown',
          address_1: 'Academy Campus',
          address_2: 'Wigtown Lane',
          town: 'Wigtown',
          postcode: 'W1G 1AA',
          status: 'Open',
          organisation_type: 'Multi-academy trust',
        }
      end

      before do
        create_trust_csv_file(filename, [attrs])
        @service = described_class.new(TrustDataFile.new(filename))
      end

      after do
        remove_file(filename)
      end

      it 'updates the existing trust record' do
        @service.import_trusts
        expect(trust.reload).to have_attributes(
          gias_group_uid: '4001',
          companies_house_number: '09933123',
          name: 'Academy of Wigtown',
          address_1: 'Academy Campus',
          address_2: 'Wigtown Lane',
          town: 'Wigtown',
          postcode: 'W1G 1AA',
          status: 'open',
          organisation_type: 'multi_academy_trust',
        )
      end
    end
  end
end
