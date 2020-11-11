require 'rails_helper'

RSpec.describe SchoolDataExporter, type: :model do
  let(:school) { create(:school) }
  let(:filename) { Rails.root.join('tmp/school_test_data.csv') }

  subject(:exporter) { described_class.new(filename) }

  context 'when exporting school data' do
    around do |example|
      school
      exporter.export_schools
      example.run
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

  context 'when exporting single academy trusts' do
    let(:sat) { create(:trust, :single_academy_trust, companies_house_number: nil) }

    around do |example|
      school.update!(responsible_body: sat)
      exporter.export_schools
      example.run
      remove_file(filename)
    end

    it 'handles trusts that have no companies house number' do
      data = CSV.parse(File.read(filename), headers: true)
      expect(data.count).to eq(School.count)

      found = false
      data.each do |row|
        if row['School URN + School Name'] == "#{school.urn} #{school.name}"
          expect(row['Responsible body URN']).to be_blank
          found = true
        end
      end
      expect(found).to be true
    end
  end
end
