require 'rails_helper'

RSpec.describe SchoolDataFile, type: :model do
  describe '#schools' do
    let(:filename) { Rails.root.join('tmp/school_test_data.csv') }

    context 'when a school is open and not an excluded type' do
      let(:attrs) do
        {
          urn: '100001',
          name: 'Big School',
          responsible_body: 'Camden',
          address_1: '12 High St',
          town: 'London',
          postcode: 'NW1 1AA',
          status: 'Open',
          type: 'Voluntary aided school',
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
          responsible_body: 'Camden',
          address_1: '12 High St',
          town: 'London',
          postcode: 'NW1 1AA',
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
  end
end
