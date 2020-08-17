require 'rails_helper'

RSpec.describe SchoolDataFile, type: :model do
  describe '#schools' do
    let(:datafile) { file_fixture('school_data.csv') }
    let(:sdf) { SchoolDataFile.new(datafile) }

    it 'parses a csv data file into school records' do
      schools = sdf.schools
      expect(schools.count).to eq(7)

      expect(schools[0]).to include(
        urn: '100000',
        name: 'Sir Teddy Pineapple Foundation Primary School',
        responsible_body: 'Bristol, City of',
      )
      expect(schools[1]).to include(
        urn: '100003',
        name: 'City of London School',
        responsible_body: 'City of London',
      )
      expect(schools[2]).to include(
        urn: '100005',
        name: 'Clocktower High',
        responsible_body: 'Aloha Overseas Establishments',
      )
      expect(schools[3]).to include(
        urn: '100007',
        name: 'East Town Pupil Referral Unit',
        responsible_body: 'Birmingham',
      )
      expect(schools[4]).to include(
        urn: '100009',
        name: 'Salford Primary School',
        responsible_body: 'Salford',
      )
      expect(schools[5]).to include(
        urn: '100010',
        name: 'Waterfront Secondary School',
        responsible_body: 'North Tyneside',
      )
      expect(schools[6]).to include(
        urn: '100012',
        name: 'Hightop Primary School',
        responsible_body: 'North Somerset',
      )
    end
  end
end
