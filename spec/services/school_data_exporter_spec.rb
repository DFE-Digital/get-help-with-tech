require 'rails_helper'

RSpec.describe SchoolDataExporter, type: :model do
  let(:school) { create(:school) }
  let(:filename) { Rails.root.join('tmp/school_test_data.csv') }
  let(:exporter) { described_class.new(filename) }

  context 'when exporting school data' do
    before do
      exporter.export_schools
    end

    after do
      remove_file(filename)
    end

    it 'creates a CSV file' do
      expect(File.exist?(filename)).to be true
    end

    it 'includes a heading row and all of the Schools in the CSV file' do
      line_count = `wc -l "#{filename}"`.split.first.to_i
      expect(line_count).to eq(School.count + 1)
    end
  end
end
