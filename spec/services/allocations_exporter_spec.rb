require 'rails_helper'

RSpec.describe AllocationsExporter, type: :model do
  let(:school) { create(:school, :can_order, :with_std_device_allocation) }
  let(:filename) { Rails.root.join('tmp/allocations_exporter_test_data.csv') }

  context 'when given a filename' do
    subject(:exporter) { described_class.new(filename) }

    before do
      school
      exporter.export
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

  context 'when exporting schools in a virtual_cap_pool' do
    subject(:exporter) { described_class.new }

    let(:trust) { create(:trust, :multi_academy_trust, :vcap_feature_flag) }
    let(:schools) { create_list(:school, 2, :in_lockdown, responsible_body: trust) }
    let(:csv) { CSV.parse(exporter.export(School.where(responsible_body_id: trust.id)), headers: true) }
    let(:mock_response) { instance_double(HTTP::Response) }

    before do
      stub_request(:post, 'http://computacenter.example.com/').to_return(status: 200, body: '', headers: {})
      create(:preorder_information, :rb_will_order, school: schools.first)
      create(:preorder_information, :rb_will_order, school: schools.last)
      create(:school_device_allocation, device_type: 'std_device', school: schools.first, allocation: 20, cap: 20, devices_ordered: 10)
      create(:school_device_allocation, device_type: 'std_device', school: schools.last, allocation: 25, cap: 5, devices_ordered: 5)

      create(:school_device_allocation, device_type: 'coms_device', school: schools.first, allocation: 21, cap: 21, devices_ordered: 11)
      create(:school_device_allocation, device_type: 'coms_device', school: schools.last, allocation: 26, cap: 6, devices_ordered: 6)
      trust.add_school_to_virtual_cap_pools!(schools.last)
      trust.add_school_to_virtual_cap_pools!(schools.first)
    end

    it 'includes both the raw numbers and pooled numbers' do
      expect(csv[0]['Devices allocation'].to_i).to eq(20)
      expect(csv[0]['Devices cap'].to_i).to eq(20)
      expect(csv[0]['Devices ordered'].to_i).to eq(10)
      expect(csv[0]['Pool devices allocation'].to_i).to eq(45)
      expect(csv[0]['Pool devices cap'].to_i).to eq(25)
      expect(csv[0]['Pool devices ordered'].to_i).to eq(15)

      expect(csv[0]['Routers allocation'].to_i).to eq(21)
      expect(csv[0]['Routers cap'].to_i).to eq(21)
      expect(csv[0]['Routers ordered'].to_i).to eq(11)
      expect(csv[0]['Pool routers allocation'].to_i).to eq(47)
      expect(csv[0]['Pool routers cap'].to_i).to eq(27)
      expect(csv[0]['Pool routers ordered'].to_i).to eq(17)
    end
  end
end
