require 'rails_helper'

RSpec.describe ImportDeviceAllocationsService, type: :model do
  describe 'importing device allocations' do
    let(:filename) { Rails.root.join('tmp/allocations_test_data.csv') }

    context 'when a standard device allocation does not exist' do
      let(:school) { create(:school) }
      let(:attrs) do
        {
          urn: school.urn,
          school_name: school.name,
          y3_10: '50',
          y_10: '10',
        }
      end

      before do
        create_allocations_csv_file(filename, [attrs])
        @service = described_class.new(AllocationDataFile.new(filename))
      end

      after do
        remove_file(filename)
      end

      it 'sets the correct allocation' do
        @service.import_laptop_allocations
        expect(school.reload.raw_allocation(:laptop)).to eq 50
      end
    end

    context 'when an allocation already exists' do
      let(:school) { create(:school, laptops: [1, 0, 0]) }

      let(:attrs) do
        {
          urn: school.urn,
          school_name: school.name,
          y3_10: 123,
          y10: 22,
        }
      end

      before do
        create_school_csv_file(filename, [attrs])
        service = described_class.new(AllocationDataFile.new(filename))
        service.import_laptop_allocations
      end

      after do
        remove_file(filename)
      end

      it 'updates the existing device allocation' do
        expect(school.reload.raw_allocation(:laptop)).to eq 123
      end
    end
  end
end
