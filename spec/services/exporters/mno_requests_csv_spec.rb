require 'rails_helper'

RSpec.describe Exporters::MnoRequestsCsv do
  let!(:first_school) { create(:school) }
  let!(:first_request) { create(:extra_mobile_data_request, school: first_school) }

  let!(:second_rb) { create(:trust) }
  let!(:second_request) { create(:extra_mobile_data_request, responsible_body: second_rb) }

  subject(:exporter) { described_class.new }

  describe '#call' do
    it 'exports correct headers' do
      exporter.call

      rows = CSV.read(exporter.path, headers: true)

      expect(rows.headers).to eql(described_class::HEADERS)
    end

    it 'exports correct number of rows' do
      exporter.call

      rows = CSV.read(exporter.path, headers: true)

      expect(rows.size).to be(2)
    end

    it 'exports correct data' do
      exporter.call

      rows = CSV.read(exporter.path, headers: true)

      expect(rows[0]['id']).to eql(first_request.id.to_s)
      expect(rows[0]['mobile_network_id']).to eql(first_request.mobile_network_id.to_s)
      expect(rows[0]['brand']).to eql(first_request.mobile_network.brand)
      expect(rows[0]['urn']).to eql(first_request.school.urn.to_s)
      expect(rows[0]['ukprn']).to eql(first_request.school.ukprn)
      expect(rows[0]['school_name']).to eql(first_request.school.name)
      expect(rows[0]['responsible_body_id']).to eql(first_request.responsible_body_id.to_s)
      expect(rows[0]['responsible_body_name']).to eql(first_request.responsible_body.name)
      expect(rows[0]['status']).to eql(first_request.status)
      expect(rows[0]['contract_type']).to eql(first_request.contract_type)
      expect(rows[0]['created_at']).to eql(first_request.created_at.to_s)
      expect(rows[0]['created_at_date']).to eql(first_request.created_at.strftime('%d/%m/%Y'))
      expect(rows[0]['updated_at']).to eql(first_request.updated_at.to_s)
      expect(rows[0]['updated_at_date']).to eql(first_request.updated_at.strftime('%d/%m/%Y'))

      expect(rows[1]['id']).to eql(second_request.id.to_s)
      expect(rows[1]['mobile_network_id']).to eql(second_request.mobile_network_id.to_s)
      expect(rows[1]['brand']).to eql(second_request.mobile_network.brand)
      expect(rows[1]['urn']).to be_nil
      expect(rows[1]['ukprn']).to be_nil
      expect(rows[1]['school_name']).to be_nil
      expect(rows[1]['responsible_body_id']).to eql(second_request.responsible_body_id.to_s)
      expect(rows[1]['responsible_body_name']).to eql(second_request.responsible_body.name)
      expect(rows[1]['status']).to eql(second_request.status)
      expect(rows[1]['contract_type']).to eql(second_request.contract_type)
      expect(rows[1]['created_at']).to eql(second_request.created_at.to_s)
      expect(rows[1]['created_at_date']).to eql(second_request.created_at.strftime('%d/%m/%Y'))
      expect(rows[1]['updated_at']).to eql(second_request.updated_at.to_s)
      expect(rows[1]['updated_at_date']).to eql(second_request.updated_at.strftime('%d/%m/%Y'))
    end
  end

  describe '#path' do
    it 'returns path to csv' do
      expect(exporter.path).to be_present
      expect(File.exist?(exporter.path)).to be_truthy
    end
  end

  describe '#delete_generated_csv!' do
    it 'deletes the generated csv file from disk' do
      exporter.call
      expect(File.exist?(exporter.path)).to be_truthy
      exporter.delete_generated_csv!
      expect(File.exist?(exporter.path)).to be_falsey
    end
  end
end
