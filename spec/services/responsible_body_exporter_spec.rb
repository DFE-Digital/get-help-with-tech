require 'rails_helper'

RSpec.describe ResponsibleBodyExporter, type: :model do
  let(:responsible_body) { create(:trust) }
  let(:filename) { Rails.root.join('tmp/responsible_bodies_test_data.csv') }

  subject(:exporter) { described_class.new(filename) }

  context 'when exporting responsible_body data' do
    before do
      responsible_body
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

  context 'when exporting single academy trusts' do
    let(:sat) { create(:trust, :single_academy_trust, companies_house_number: nil) }

    before do
      sat
      exporter.export_responsible_bodies
    end

    after do
      remove_file(filename)
    end

    it 'handles trusts that have no companies house number' do
      data = CSV.parse(File.read(filename), headers: true)
      expect(data.count).to eq(ResponsibleBody.count)

      found = false
      data.each do |row|
        if row['Responsible Body Name'] == sat.name
          expect(row['Responsible body URN']).to be_blank
          found = true
        end
      end
      expect(found).to be true
    end
  end
end
