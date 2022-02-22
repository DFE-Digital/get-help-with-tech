require 'rails_helper'

RSpec.describe DeviceSupplier::ExportAllocationsToFileService, type: :model do
  describe '#call' do
    let(:csv) { CSV.read(filename, headers: true) }
    let(:expected_headers) { DeviceSupplier::AllocationReport.headers }
    let(:filename) { Rails.root.join('tmp/device_supplier_export_allocations_test_data.csv') }
    let(:rb) { school.responsible_body }
    let(:school) { create(:school, :manages_orders, :can_order, laptops: [1, 0, 0]) }
    let(:school_csv_row) { csv.find { |row| row['urn'] == school.urn.to_s } }
    let(:school_ids) { School.ids }

    after do
      remove_file(filename)
    end

    subject(:service) { described_class.new(filename, school_ids:) }

    before { stub_computacenter_outgoing_api_calls }

    context 'when given a filename' do
      before do
        school
        service.call
      end

      it 'creates a CSV file' do
        expect(File.exist?(filename)).to be true
      end

      it 'includes a heading row and all Schools in the CSV file' do
        line_count = `wc -l "#{filename}"`.split.first.to_i
        expect(line_count).to eq(School.count + 1)
      end

      it 'includes the correct headers' do
        expect(csv.headers).to match_array(expected_headers)
      end
    end

    context 'when devices are managed by the school' do
      before do
        school
        service.call
      end

      it 'displays "school" in the "who_orders" column' do
        expect(school_csv_row['who_orders']).to eq('school')
      end

      it 'has a ship_to value equal to the school computacenter_refernce' do
        expect(school_csv_row['ship_to']).to eq(school.computacenter_reference)
      end

      it 'has a sold_to value equal to the school computacenter_refernce' do
        expect(school_csv_row['sold_to']).to eq(rb.sold_to)
      end

      it 'has a responsible body name' do
        expect(school_csv_row['responsible_body_name']).to eq(rb.name)
      end

      it 'has a responsible_body_id value equal to the rb computacenter_identifier' do
        expect(school_csv_row['responsible_body_id']).to eq(rb.computacenter_identifier)
      end

      it 'has an adjusted cap equal to cap' do
        expect(school_csv_row['adjusted_cap_if_vcap_enabled']).to eq(school_csv_row['cap'])
      end

      it 'displays "No" in the "virtual_cap_enabled?" column' do
        expect(school_csv_row['virtual_cap_enabled?']).to eq('No')
      end

      it 'displays "No" in the "school_in_virtual_cap?" column' do
        expect(school_csv_row['school_in_virtual_cap?']).to eq('No')
      end
    end

    context 'when the devices are centrally managed' do
      let(:rb) { create(:local_authority, :manages_centrally, :vcap) }
      let(:sibling_school_csv_row) { csv.find { |row| row['urn'] == sibling_schools.first.urn.to_s } }

      let!(:school) do
        create(:school,
               :in_lockdown,
               :centrally_managed,
               responsible_body: rb,
               laptops: [5, 4, 3])
      end

      let!(:sibling_schools) do
        create_list(:school,
                    2,
                    :in_lockdown,
                    :centrally_managed,
                    responsible_body: rb,
                    laptops: [7, 6, 4])
      end

      before do
        stub_computacenter_outgoing_api_calls
        rb.update!(laptop_allocation: 19, laptop_cap: 16, laptops_ordered: 11)
        service.call
      end

      it 'displays "responsible_body" in the "who_orders" column' do
        expect(school_csv_row['who_orders']).to eq('responsible_body')
      end

      it 'has a ship_to value equal to the school computacenter_refernce' do
        expect(school_csv_row['ship_to']).to eq(school.computacenter_reference)
      end

      it 'has a sold_to value equal to the school computacenter_refernce' do
        expect(school_csv_row['sold_to']).to eq(rb.computacenter_reference)
      end

      it 'displays "Yes" in the "virtual_cap_enabled?" column' do
        expect(school_csv_row['virtual_cap_enabled?']).to eq('Yes')
      end

      it 'displays "Yes" in the "school_in_virtual_cap?" column' do
        expect(school_csv_row['school_in_virtual_cap?']).to eq('Yes')
      end

      it 'includes both the raw numbers and pooled numbers' do
        expect(sibling_school_csv_row['allocation'].to_i).to eq(7)
        expect(sibling_school_csv_row['cap'].to_i).to eq(6)

        expect(sibling_school_csv_row['adjusted_cap_if_vcap_enabled'].to_i).to eq(9)
        expect(sibling_school_csv_row['devices_ordered'].to_i).to eq(4)

        expect(school_csv_row['allocation'].to_i).to eq(5)
        expect(school_csv_row['cap'].to_i).to eq(4)

        expect(school_csv_row['adjusted_cap_if_vcap_enabled'].to_i).to eq(8)
        expect(school_csv_row['devices_ordered'].to_i).to eq(3)
      end
    end
  end
end
