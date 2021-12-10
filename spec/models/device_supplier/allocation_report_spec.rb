require 'rails_helper'

RSpec.describe DeviceSupplier::AllocationReport do
  describe '#generate_report' do
    let(:csv_data) { [] } # we can pass CSV data as an empty array
    let(:school) { create(:school, :manages_orders, :can_order, laptops: [1, 0, 0]) }
    let(:school_ids) { School.ids }

    subject(:report_class) { described_class.new(csv_data, scope_ids: school_ids) }

    context 'when there are no schools' do
      let(:expected_data) { [described_class.headers] }

      before { report_class.generate_report }

      it 'generates correct data' do
        expect(csv_data).to eq expected_data
      end
    end

    context 'when there are multiple types of schools' do
      let(:relevent_school_count) { School.can_order.count }

      before do
        school
        report_class.generate_report
      end

      it 'includes the correct headers' do
        expect(csv_data.to_a.first).to match_array(described_class.headers)
      end

      it 'includes a heading row and all relevant schools in the CSV file' do
        line_count = csv_data.to_a.count
        expect(line_count).to eq(relevent_school_count + 1)
      end
    end
  end
end
