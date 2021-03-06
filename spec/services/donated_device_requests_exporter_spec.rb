require 'rails_helper'

RSpec.describe DonatedDeviceRequestsExporter, type: :model do
  let(:schools) { create_list(:school, 2) }
  let(:laptops_request) { create(:donated_device_request, :complete, :wants_full_amount, :wants_laptops, schools: [schools[0].id]) }
  let(:tablets_request) { create(:donated_device_request, :opt_in_some, :complete, :wants_full_amount, :wants_tablets, schools: [schools[1].id], responsible_body: schools[1].responsible_body) }
  let(:filename) { Rails.root.join('tmp/donated_devices_exporter_test_data.csv') }

  context 'when given a filename' do
    subject(:exporter) { described_class.new(filename) }

    before do
      laptops_request
      tablets_request
      exporter.export
    end

    after do
      remove_file(filename)
    end

    it 'creates a CSV file' do
      expect(File.exist?(filename)).to be true
    end

    it 'includes a heading row and all of the donated device requests in the CSV file' do
      expect(DonatedDeviceRequest.complete.count).to eq(2)
      line_count = `wc -l "#{filename}"`.split.first.to_i
      expect(line_count).to eq(DonatedDeviceRequest.count + 1)
    end

    it 'includes the request information in the CSV file' do
      CSV.read(filename, headers: true).each do |request|
        record = DonatedDeviceRequest.find(request['id'])
        school = School.find(record.schools.first)
        expect(record.completed_at.utc).to be_within(1.second).of(Time.zone.parse(request['created_at']).utc)
        expect(school.urn.to_s).to eq(request['urn'])
        expect(school.computacenter_reference).to eq(request['shipTo'])
        expect(school.responsible_body.computacenter_reference).to eq(request['soldTo'])
        expect(record.user.full_name).to eq(request['full_name'])
        expect(record.user.email_address).to eq(request['email_address'])
        expect(record.user.telephone).to eq(request['telephone_number'])
        expect(record.device_types.join(',')).to eq(request['device_types'])
        expect(record.units.to_s).to eq(request['units'])
      end
    end
  end
end
