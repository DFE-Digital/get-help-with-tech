require 'rails_helper'

RSpec.describe TrustDataFile, type: :model do
  describe '#trusts' do
    let(:filename) { Rails.root.join('tmp/trust_test_data.csv') }

    context 'when a trust is a single-academy or multi-academy and has a companies house number' do
      let(:attrs) do
        [
          {
            group_uid: '1001',
            companies_house_number: '01234222',
            name: 'Little Hampton Academy',
            address_1: '12 High St',
            address_2: 'Little Hampton Count',
            town: 'London',
            postcode: 'NW1 1AA',
            status: 'Open',
            group_type: 'Multi-academy trust',
          },
          {
            group_uid: '4001',
            companies_house_number: '09933123',
            name: 'Callio Forsythe Academy',
            address_1: 'Big Academy',
            address_2: 'Strange Lane',
            town: 'Easttown',
            postcode: 'EW1 1AA',
            status: 'Closed',
            group_type: 'Single-academy trust',
          },
        ]
      end

      before do
        create_trust_csv_file(filename, attrs)
      end

      after do
        remove_file(filename)
      end

      it 'retrieves the trust data' do
        trusts = TrustDataFile.new(filename).trusts
        expect(trusts.first).to include(
          gias_group_uid: '1001',
          companies_house_number: '01234222',
          name: 'Little Hampton Academy',
          address_1: '12 High St',
          address_2: 'Little Hampton Count',
          town: 'London',
          postcode: 'NW1 1AA',
          status: 'open',
          organisation_type: 'Multi-academy trust',
        )
        expect(trusts.second).to include(
          gias_group_uid: '4001',
          companies_house_number: '09933123',
          name: 'Callio Forsythe Academy',
          address_1: 'Big Academy',
          address_2: 'Strange Lane',
          town: 'Easttown',
          postcode: 'EW1 1AA',
          status: 'closed',
          organisation_type: 'Single-academy trust',
        )
      end
    end

    context 'when a trust is has no companies house number or is not a single or multi academy trust' do
      let(:attrs) do
        [
          {
            group_uid: '3001',
            companies_house_number: '01234222',
            name: 'Little Hampton Academy',
            address_1: '12 High St',
            address_2: 'Little Hampton Count',
            town: 'London',
            postcode: 'NW1 1AA',
            status: 'Open',
            group_type: 'Trust',
          },
          {
            group_uid: '1031',
            companies_house_number: '',
            name: 'Hampton Academy',
            address_1: '14 High St',
            address_2: 'Hampton Court',
            town: 'London',
            postcode: 'NW1 1DA',
            status: 'Open',
            group_type: 'Single-academy trust',
          },
        ]
      end

      before do
        create_school_csv_file(filename, attrs)
      end

      after do
        remove_file(filename)
      end

      it 'does not retrieve the trust data' do
        trusts = TrustDataFile.new(filename).trusts
        expect(trusts).to be_empty
      end
    end
  end
end
