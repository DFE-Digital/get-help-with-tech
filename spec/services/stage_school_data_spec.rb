require 'rails_helper'

RSpec.describe StageSchoolData, type: :model do
  describe 'importing schools' do
    let(:filename) { Rails.root.join('tmp/school_test_data.csv') }

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
        }.to change { Staging::School.count }.by(1)
      end

      it 'sets the correct values on the School record' do
        @service.import_schools
        expect(Staging::School.last).to have_attributes(
          urn: 103_001,
          name: 'Little School',
          responsible_body_name: 'Camden',
          address_1: '12 High St',
          town: 'London',
          postcode: 'NW1 1AA',
          phase: 'primary',
          establishment_type: 'local_authority',
          status: 'open',
        )
      end
    end

    context 'when a school already exists' do
      let(:school) { create(:staged_school, urn: '103001') }

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
        expect(Staging::School.last).to have_attributes(
          urn: 103_001,
          name: 'Little School',
          responsible_body_name: 'Camden',
          address_1: '12 High St',
          town: 'London',
          postcode: 'NW1 1AA',
          phase: 'primary',
          establishment_type: 'local_authority',
        )
      end
    end
  end

  describe 'importing school links' do
    let(:filename) { Rails.root.join('tmp/school_link_test_data.csv') }

    context 'when a school already exists without links' do
      let!(:school) { create(:staged_school, urn: '103001') }
      let(:attrs) do
        [
          {
            urn: '103001',
            link_urn: '142311',
            link_type: 'Successor',
          },
          { urn: '103001',
            link_urn: '144321',
            link_type: 'Successor',
          },
        ]
      end

      before do
        create_school_links_csv_file(filename, attrs)
        @service = described_class.new(SchoolLinksDataFile.new(filename))
      end

      after do
        remove_file(filename)
      end

      it 'adds the school links' do
        expect {
          @service.import_school_links
        }.to change { Staging::SchoolLink.count }.by(2)

        expect(Staging::SchoolLink.all.map { |sl| [sl.link_urn, sl.link_type] }).to eq([[142_311, 'Successor'],[144_321, 'Successor']])
      end
    end
  end
end
