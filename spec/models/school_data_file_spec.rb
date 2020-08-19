require 'rails_helper'

RSpec.describe SchoolDataFile, type: :model do
  describe '#schools' do
    let(:filename) { Rails.root.join('tmp/school_test_data.csv') }

    context 'when a school is open and not an excluded type' do
      let(:attrs) do
        {
          urn: '103001',
          name: 'Little School',
          responsible_body: 'Camden',
          address_1: '12 High St',
          town: 'London',
          postcode: 'NW1 1AA',
          status: 'Open',
          type: 'Voluntary aided school',
          trusts_flag: '0',
          phase: 'Primary',
          group_type: 'Local authority maintained schools',
        }
      end

      before do
        create_school_csv_file(filename, [attrs])
      end

      after do
        remove_file(filename)
      end

      it 'retrieves the school data' do
        schools = SchoolDataFile.new(filename).schools
        expect(schools[0]).to include(
          urn: '103001',
          name: 'Little School',
          responsible_body: 'Camden',
          address_1: '12 High St',
          town: 'London',
          postcode: 'NW1 1AA',
          phase: 'primary',
          establishment_type: 'local_authority',
        )
      end
    end

    context 'when a school is closed' do
      let(:attrs) do
        {
          urn: '100001',
          name: 'Big School',
          responsible_body: 'Camden',
          address_1: '12 High St',
          town: 'London',
          postcode: 'NW1 1AA',
          status: 'Closed',
          type: 'Voluntary aided school',
          trusts_flag: '0',
          phase: 'Secondary',
          group_type: 'Local authority maintained schools',
        }
      end

      before do
        create_school_csv_file(filename, [attrs])
      end

      after do
        remove_file(filename)
      end

      it 'does not retrieve the school data' do
        schools = SchoolDataFile.new(filename).schools
        expect(schools).to be_empty
      end
    end

    context 'when a school is open but an excluded type' do
      let(:attrs) do
        {
          urn: '100001',
          name: 'Big School',
          responsible_body: 'Camden',
          address_1: '12 High St',
          town: 'London',
          postcode: 'NW1 1AA',
          status: 'Open',
          type: 'Other independent school',
          trusts_flag: '0',
          phase: 'Secondary',
          group_type: 'Independent schools',
        }
      end

      before do
        create_school_csv_file(filename, [attrs])
      end

      after do
        remove_file(filename)
      end

      it 'does not retrieve the school data' do
        schools = SchoolDataFile.new(filename).schools
        expect(schools).to be_empty
      end
    end

    context 'when a school is managed by a Multi-Academy Trust' do
      let(:attrs) do
        {
          urn: '100001',
          name: 'Big School',
          responsible_body: 'Camden',
          address_1: '12 High St',
          town: 'London',
          postcode: 'NW1 1AA',
          status: 'Open',
          type: 'Academy sponsor led',
          trusts_flag: '3',
          trusts_name: 'The Multi-Trust Academy',
          phase: 'Secondary',
          group_type: 'Academies',
        }
      end

      before do
        create_school_csv_file(filename, [attrs])
      end

      after do
        remove_file(filename)
      end

      it 'retrieves the school data' do
        schools = SchoolDataFile.new(filename).schools
        expect(schools[0]).to include(
          urn: '100001',
          name: 'Big School',
          responsible_body: 'The Multi-Trust Academy',
          address_1: '12 High St',
          town: 'London',
          postcode: 'NW1 1AA',
          phase: 'secondary',
          establishment_type: 'academy',
        )
      end
    end

    context 'when a school is managed by a Single-Academy Trust' do
      let(:attrs) do
        {
          urn: '100021',
          name: 'All Phase School',
          responsible_body: 'Camden',
          address_1: '12 High St',
          town: 'London',
          postcode: 'NW1 1AA',
          status: 'Open',
          type: 'Academy sponsor led',
          trusts_flag: '5',
          trusts_name: 'The Single-Trust Academy',
          phase: 'All-through',
          group_type: 'Academies',
        }
      end

      before do
        create_school_csv_file(filename, [attrs])
      end

      after do
        remove_file(filename)
      end

      it 'retrieves the school data' do
        schools = SchoolDataFile.new(filename).schools
        expect(schools[0]).to include(
          urn: '100021',
          name: 'All Phase School',
          responsible_body: 'The Single-Trust Academy',
          address_1: '12 High St',
          town: 'London',
          postcode: 'NW1 1AA',
          phase: 'all_through',
          establishment_type: 'academy',
        )
      end
    end
  end
end
