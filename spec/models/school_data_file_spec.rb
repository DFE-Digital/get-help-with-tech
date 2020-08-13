require 'rails_helper'

RSpec.describe SchoolDataFile, type: :model do
  describe '#schools' do
    let(:datafile) { file_fixture('school_data.csv') }
    let(:sdf) { SchoolDataFile.new(datafile) }

    it 'parses a csv data file into school records' do
      schools = sdf.schools
      puts schools.inspect
      expect(schools.count).to eq(7)
    end
  end
end
