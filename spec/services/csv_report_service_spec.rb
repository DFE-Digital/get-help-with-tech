require 'rails_helper'

RSpec.describe CsvReportService do
  describe '#call' do
    let(:csv_generator) { described_class.new(report_class, scope_ids: []) }
    let(:csv_data) { CSV.parse report_data }
    let(:csv_expected_data) { [report_class.headers] }
    let(:report_class) { Support::UserReport }
    let(:report_data) { csv_generator.call }

    before { report_data }

    it 'generates report' do
      expect(csv_data).to eq csv_expected_data
    end
  end
end
