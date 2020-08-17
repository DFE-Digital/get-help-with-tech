require 'rails_helper'
require 'shared/csv_file'

RSpec.describe SchoolDataFile, type: :model do
  describe '#schools' do
    let(:filename) { Rails.root.join('tmp/school_test_data.csv') }

    # let(:datafile) { file_fixture('school_data.csv') }
    # let(:sdf) { SchoolDataFile.new(datafile) }

    # before do
    #   @datafile = Tempfile.new
    # end
    #
    # after do
    #   @datafile.close
    #   @datafile.unlink
    # end

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
          type: 'Voluntary aided school'
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
          type: 'Voluntary aided school'
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
          type: 'Other independent school'
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

    # it 'parses a csv data file into school records' do
    #   schools = sdf.schools
    #   expect(schools.count).to eq(7)
    #
    #   expect(schools[0]).to include(
    #     urn: '100000',
    #     name: 'Sir Teddy Pineapple Foundation Primary School',
    #     responsible_body: 'Bristol, City of',
    #   )
    #   expect(schools[1]).to include(
    #     urn: '100003',
    #     name: 'City of London School',
    #     responsible_body: 'City of London',
    #   )
    #   expect(schools[2]).to include(
    #     urn: '100005',
    #     name: 'Clocktower High',
    #     responsible_body: 'Aloha Overseas Establishments',
    #   )
    #   expect(schools[3]).to include(
    #     urn: '100007',
    #     name: 'East Town Pupil Referral Unit',
    #     responsible_body: 'Birmingham',
    #   )
    #   expect(schools[4]).to include(
    #     urn: '100009',
    #     name: 'Salford Primary School',
    #     responsible_body: 'Salford',
    #   )
    #   expect(schools[5]).to include(
    #     urn: '100010',
    #     name: 'Waterfront Secondary School',
    #     responsible_body: 'North Tyneside',
    #   )
    #   expect(schools[6]).to include(
    #     urn: '100012',
    #     name: 'Hightop Primary School',
    #     responsible_body: 'North Somerset',
    #   )
    # end
  end
end
