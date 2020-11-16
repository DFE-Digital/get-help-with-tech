require 'rails_helper'

RSpec.describe VirtualCapPool, type: :model do
  let(:local_authority) { create(:local_authority) }

  subject(:pool) { local_authority.virtual_cap_pools.std_device.create! }

  describe '#add_school' do
    context 'when school belongs to the responsible body' do
      let(:schools) { create_list(:school, 2, :with_std_device_allocation, responsible_body: local_authority) }

      before do
        schools.first.std_device_allocation.update!(cap: 20, allocation: 30, devices_ordered: 10)
        schools.last.std_device_allocation.update!(cap: 10, allocation: 30, devices_ordered: 1)
      end

      it 'adds the allocation values to the pool' do
        pool.add_school(schools.first)
        expect(pool.cap).to eq(20)
        expect(pool.devices_ordered).to eq(10)

        pool.add_school(schools.last)
        expect(pool.cap).to eq(30)
        expect(pool.devices_ordered).to eq(11)
      end
    end

    context 'when the school does not belong to the responsible body' do
      let(:non_rb_school) { create(:school, :with_std_device_allocation) }

      before do
        non_rb_school.std_device_allocation.update!(cap: 20, allocation: 30, devices_ordered: 10)
      end

      it 'does not add the schools allocation to the pool' do
        pool.add_school(non_rb_school)
        expect(pool.cap).to eq(0)
        expect(pool.devices_ordered).to eq(0)
      end
    end
  end

  describe '#recalculate_caps!' do
    let(:schools) { create_list(:school, 2, :with_std_device_allocation, responsible_body: local_authority) }

    before do
      schools.first.std_device_allocation.update!(cap: 20, allocation: 30, devices_ordered: 10)
      schools.last.std_device_allocation.update!(cap: 10, allocation: 30, devices_ordered: 1)
      schools.each { |s| pool.add_school(s) }
    end

    it 'recalculates the cap and devices_ordered totals for the schools in the pool' do
      schools.first.std_device_allocation.update!(cap: 40, allocation: 40, devices_ordered: 26)

      pool.recalculate_caps!

      expect(pool.cap).to eq(50)
      expect(pool.devices_ordered).to eq(27)
    end
  end
end
