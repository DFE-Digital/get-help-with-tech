require 'rails_helper'

RSpec.describe DeviceSupplierExportAllocationsService, type: :model do
  describe '#call' do
    let(:school) { create(:school, :manages_orders, :can_order, :with_std_device_allocation) }
    let(:rb) { school.responsible_body }
    let(:filename) { Rails.root.join('tmp/device_supplier_export_allocations_test_data.csv') }
    let(:csv) { CSV.read(filename, headers: true) }
    let(:school_csv_row) { csv[0] }
    let(:service_call) { service.call }

    after do
      remove_file(filename)
    end

    subject(:service) { described_class.new(filename) }

    context 'when given a filename' do
      before do
        school
        service_call
      end

      it 'creates a CSV file' do
        expect(File.exist?(filename)).to be true
      end

      it 'includes a heading row and all Schools in the CSV file' do
        line_count = `wc -l "#{filename}"`.split.first.to_i
        expect(line_count).to eq(School.count + 1)
      end
    end

    context 'when devices are managed by the school' do
      before do
        school
        service_call
      end

      it 'displays "school" in the "who_orders" column' do
        expect(school_csv_row['who_orders']).to eq('school')
      end

      it 'has a ship_to value equal to the school computacenter_refernce' do
        expect(school_csv_row['ship_to']).to eq(school.computacenter_reference)
      end

      it 'has a sold_to value equal to the school computacenter_refernce' do
        expect(school_csv_row['sold_to']).to eq(rb.computacenter_reference)
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
      let(:rb) { create(:local_authority, :manages_centrally, :vcap_feature_flag) }
      let(:create_vcap_pool) { ([school] + sibling_schools).each { |school| AddSchoolToVirtualCapPoolService.new(school).call } }
      let(:sibling_school_csv_row) { csv[-1] }

      let!(:school) do
        create(:school,
               :centrally_managed,
               :with_std_device_allocation,
               responsible_body: rb,
               laptop_allocation: 5, laptop_cap: 4, laptops_ordered: 3)
      end

      let(:sibling_schools) do
        create_list(:school,
                    2,
                    :centrally_managed,
                    :with_std_device_allocation,
                    responsible_body: rb,
                    laptop_allocation: 7, laptop_cap: 6, laptops_ordered: 4)
      end

      before do
        stub_computacenter_outgoing_api_calls
        create_vcap_pool
        rb.reload
        service_call
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