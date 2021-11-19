require 'rails_helper'

RSpec.describe UpdateSchoolDevicesService do
  describe '#call' do
    before { stub_computacenter_outgoing_api_calls }

    context 'case 1' do
      let!(:rb) { create(:trust, :manages_centrally, :vcap) }
      let!(:schools) do
        [
          create(:school, :centrally_managed, :in_lockdown, responsible_body: rb, laptops: [5, 0, 0, 0]),
          create(:school, :centrally_managed, :in_lockdown, responsible_body: rb, laptops: [3, 0, 0, 0]),
          create(:school, :centrally_managed, :in_lockdown, responsible_body: rb, laptops: [2, 0, 0, 0]),
        ]
      end

      before { rb.calculate_vcap(:laptop) }

      it 'updates laptop allocation numbers' do
        expect(schools[0].raw_laptops_full).to eq([5, 0, 0, 0])
        expect(schools[1].raw_laptops_full).to eq([3, 0, 0, 0])
        expect(schools[2].raw_laptops_full).to eq([2, 0, 0, 0])
        expect(rb.laptops).to eq([10, 10, 0])
        described_class.new(school: schools[2], laptops_ordered: 15, notify_school: false, notify_computacenter: false).call
        expect(schools[0].reload.raw_laptops_full).to eq([5, 0, -5, 0])
        expect(schools[1].reload.raw_laptops_full).to eq([3, 0, -3, 0])
        expect(schools[2].reload.raw_laptops_full).to eq([2, 0, 13, 15])
        expect(rb.reload.laptops).to eq([10, 15, 15])
        described_class.new(school: schools[2], laptops_ordered: 14, notify_school: false, notify_computacenter: false).call
        expect(schools[0].reload.raw_laptops_full).to eq([5, 0, -5, 0])
        expect(schools[1].reload.raw_laptops_full).to eq([3, 0, -3, 0])
        expect(schools[2].reload.raw_laptops_full).to eq([2, 0, 12, 14])
        expect(rb.reload.laptops).to eq([10, 14, 14])
        described_class.new(school: schools[2], laptops_ordered: 0, notify_school: false, notify_computacenter: false).call
        expect(schools[0].reload.raw_laptops_full).to eq([5, 0, 0, 0])
        expect(schools[1].reload.raw_laptops_full).to eq([3, 0, 0, 0])
        expect(schools[2].reload.raw_laptops_full).to eq([2, 0, 0, 0])
        expect(rb.reload.laptops).to eq([10, 10, 0])
      end
    end

    context 'case 2' do
      let!(:rb) { create(:trust, :manages_centrally, :vcap) }
      let!(:schools) do
        [
          create(:school, :centrally_managed, responsible_body: rb, laptops: [5, 0, 0, 0]),
          create(:school, :centrally_managed, :in_lockdown, responsible_body: rb, laptops: [3, 0, 0, 0]),
          create(:school, :centrally_managed, :in_lockdown, responsible_body: rb, laptops: [2, 0, 0, 0]),
        ]
      end

      before { rb.calculate_vcap(:laptop) }

      it 'updates laptop allocation numbers' do
        expect(schools[0].raw_laptops_full).to eq([5, 0, 0, 0])
        expect(schools[1].raw_laptops_full).to eq([3, 0, 0, 0])
        expect(schools[2].raw_laptops_full).to eq([2, 0, 0, 0])
        expect(rb.laptops).to eq([10, 5, 0])
        described_class.new(school: schools[2], laptops_ordered: 15, notify_school: false, notify_computacenter: false).call
        expect(schools[0].reload.raw_laptops_full).to eq([5, 0, 0, 0])
        expect(schools[1].reload.raw_laptops_full).to eq([3, 0, -3, 0])
        expect(schools[2].reload.raw_laptops_full).to eq([2, 0, 13, 15])
        expect(rb.reload.laptops).to eq([10, 15, 15])
        described_class.new(school: schools[2], laptops_ordered: 14, notify_school: false, notify_computacenter: false).call
        expect(schools[0].reload.raw_laptops_full).to eq([5, 0, 0, 0])
        expect(schools[1].reload.raw_laptops_full).to eq([3, 0, -3, 0])
        expect(schools[2].reload.raw_laptops_full).to eq([2, 0, 12, 14])
        expect(rb.reload.laptops).to eq([10, 14, 14])
        described_class.new(school: schools[2], laptops_ordered: 0, notify_school: false, notify_computacenter: false).call
        expect(schools[0].reload.raw_laptops_full).to eq([5, 0, 0, 0])
        expect(schools[1].reload.raw_laptops_full).to eq([3, 0, 0, 0])
        expect(schools[2].reload.raw_laptops_full).to eq([2, 0, 0, 0])
        expect(rb.reload.laptops).to eq([10, 5, 0])
      end
    end
  end
end
