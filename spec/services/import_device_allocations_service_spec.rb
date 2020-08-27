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

      it 'creates a new device allocation record' do
        expect {
          @service.import_device_allocations
        }.to change { SchoolDeviceAllocation.count }.by(1)
      end

      it 'sets the correct allocation on the device allocation record' do
        @service.import_device_allocations
        expect(school.std_device_allocation.allocation).to eq 50
      end
    end

    context 'when an allocation already exists' do
      let(:school) { create(:school, :with_std_device_allocation) }
      let(:allocation_id) { school.std_device_allocation.id }

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
        service.import_device_allocations
        school.reload
      end

      after do
        remove_file(filename)
      end

      it 'updates the existing device allocation record' do
        expect(school.std_device_allocation.id).to eq allocation_id
        expect(school.std_device_allocation.allocation).to eq 123
      end
    end
  end
end
