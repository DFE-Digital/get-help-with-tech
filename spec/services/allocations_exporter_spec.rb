require 'rails_helper'

RSpec.describe AllocationsExporter, type: :model do
  let(:school) { create(:school, :can_order, laptops: [1, 0, 0]) }
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

    let(:trust) { create(:trust, :manages_centrally, :multi_academy_trust, :vcap_feature_flag) }
    let(:schools) { create_list(:school, 2, :in_lockdown, responsible_body: trust) }
    let(:csv) { CSV.parse(exporter.export(School.where(responsible_body_id: trust.id)), headers: true) }
    let(:mock_response) { instance_double(HTTP::Response) }

    before do
      stub_request(:post, 'http://computacenter.example.com/').to_return(status: 200, body: '', headers: {})
      UpdateSchoolDevicesService.new(school: schools.first,
                                     order_state: :can_order_for_specific_circumstances,
                                     laptop_allocation: 20,
                                     laptop_cap: 20,
                                     laptops_ordered: 10,
                                     router_allocation: 21,
                                     router_cap: 21,
                                     routers_ordered: 11).call
      UpdateSchoolDevicesService.new(school: schools.last,
                                     order_state: :can_order_for_specific_circumstances,
                                     laptop_allocation: 25,
                                     laptop_cap: 5,
                                     laptops_ordered: 5,
                                     router_allocation: 26,
                                     router_cap: 6,
                                     routers_ordered: 6).call
      SchoolSetWhoManagesOrdersService.new(schools.first, :responsible_body).call
      SchoolSetWhoManagesOrdersService.new(schools.last, :responsible_body).call
      trust.reload
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
