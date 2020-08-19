require 'rails_helper'

RSpec.describe ImportSchoolsService, type: :model do
  describe 'importing schools' do
    let(:filename) { Rails.root.join('tmp/school_test_data.csv') }
    let!(:local_authority) { create(:local_authority, name: 'Camden') }

    context 'when a school does not already exist' do
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
        @service = described_class.new(SchoolDataFile.new(filename))
      end

      after do
        remove_file(filename)
      end

      it 'creates a new school record' do
        expect {
          @service.import_schools
        }.to change { School.count }.by(1)
      end

      it 'sets the correct values on the School record' do
        @service.import_schools
        expect(School.last).to have_attributes(
          urn: 103_001,
          name: 'Little School',
          responsible_body_id: local_authority.id,
          address_1: '12 High St',
          town: 'London',
          postcode: 'NW1 1AA',
          phase: 'primary',
          establishment_type: 'local_authority',
        )
      end
    end

    context 'when a school already exists' do
      let(:school) { create(:school, urn: '103001') }

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
        @service = described_class.new(SchoolDataFile.new(filename))
      end

      after do
        remove_file(filename)
      end

      it 'updates the existing school record' do
        @service.import_schools
        expect(School.last).to have_attributes(
          urn: 103_001,
          name: 'Little School',
          responsible_body_id: local_authority.id,
          address_1: '12 High St',
          town: 'London',
          postcode: 'NW1 1AA',
          phase: 'primary',
          establishment_type: 'local_authority',
        )
      end
    end
  end
end
