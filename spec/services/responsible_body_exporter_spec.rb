require 'rails_helper'

RSpec.describe ResponsibleBodyExporter, type: :model do
  let(:responsible_body) { create(:trust) }
  let(:filename) { Rails.root.join('tmp/responsible_bodies_test_data.csv') }
  let(:exporter) { described_class.new(filename) }

  context 'when exporting responsible_body data' do
    before do
      exporter.export_responsible_bodies
    end

    after do
      remove_file(filename)
    end

    it 'creates a CSV file' do
      expect(File.exist?(filename)).to be true
    end

    it 'includes a heading row and all of the responsible bodies in the CSV file' do
      line_count = `wc -l "#{filename}"`.split.first.to_i
      expect(line_count).to eq(ResponsibleBody.count + 1)
    end
  end
end
