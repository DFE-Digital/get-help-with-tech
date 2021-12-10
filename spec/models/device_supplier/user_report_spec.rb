require 'rails_helper'

RSpec.describe DeviceSupplier::UserReport do
  describe '#generate_report' do
    let(:csv_data) { [] } # we can pass CSV data as an empty array
    let(:computacenter_user) { create(:computacenter_user) }
    let(:local_authority_user) { create(:local_authority_user) }
    let(:school_user) { create(:school_user) }
    let(:support_user) { create(:support_user) }
    let(:user_ids) { User.ids }

    subject(:report_class) { described_class.new(csv_data, scope_ids: user_ids) }

    context 'when there are no users' do
      let(:expected_data) { [described_class.headers] }

      before { report_class.generate_report }

      it 'generates correct data' do
        expect(csv_data).to eq expected_data
      end
    end

    context 'when there are multiple types of users' do
      let(:relevent_user_count) { User.relevant_to_device_supplier.count }

      before do
        school_user
        local_authority_user
        support_user
        computacenter_user
        report_class.generate_report
      end

      it 'includes the correct headers' do
        expect(csv_data.to_a.first).to match_array(described_class.headers)
      end

      it 'includes a heading row and all relevant Users in the CSV file' do
        line_count = csv_data.to_a.count
        expect(line_count).to eq(relevent_user_count + 1)
      end
    end
  end
end
