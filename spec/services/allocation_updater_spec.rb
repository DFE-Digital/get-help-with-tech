require 'rails_helper'

RSpec.describe AllocationUpdater do
  subject(:service) do
    described_class.new(school: school, device_type: 'std_device', value: 100)
  end

  context 'allocation exists and school can order full allocation' do
    let(:school) { create(:school, :in_lockdown) }

    before do
      create(:school_device_allocation,
             :with_std_allocation,
             allocation: 10,
             cap: 10,
             school: school)
    end

    it 'updates cap to match allocation' do
      service.call
      allocation = school.std_device_allocation.reload
      expect(allocation.allocation).to be(100)
      expect(allocation.cap).to be(100)
    end
  end

  context 'allocation does not exist and school can order full allocation' do
    let(:school) { create(:school, :in_lockdown) }

    it 'updates cap to match allocation' do
      service.call
      allocation = school.std_device_allocation
      expect(allocation.allocation).to be(100)
      expect(allocation.cap).to be(100)
      expect(allocation).to be_persisted
    end
  end

  context 'when school can order for specific circumstances' do
    let(:school) { create(:school, :can_order_for_specific_circumstances) }

    before do
      create(:school_device_allocation,
             :with_std_allocation,
             allocation: 10,
             cap: 10,
             school: school)
    end

    it 'leaves cap value as is' do
      service.call
      allocation = school.std_device_allocation.reload
      expect(allocation.allocation).to be(100)
      expect(allocation.cap).to be(10)
    end
  end
end
