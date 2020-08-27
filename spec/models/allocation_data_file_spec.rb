require 'rails_helper'

RSpec.describe AllocationDataFile, type: :model do
  describe '#allocations' do
    let(:filename) { Rails.root.join('tmp/allocation_test_data.csv') }

    context 'when a school has an allocation entry' do
      let(:attrs) do
        {
          urn: '103001',
          school_name: 'Little School',
          y3_10: '23',
          y10: '0',
        }
      end

      before do
        create_allocations_csv_file(filename, [attrs])
      end

      after do
        remove_file(filename)
      end

      it 'retrieves the allocation data' do
        allocations = described_class.new(filename).allocations
        expect(allocations.first).to include(
          urn: '103001',
          name: 'Little School',
          y3_10: 23,
          y10: 0,
        )
      end
    end
  end
end
