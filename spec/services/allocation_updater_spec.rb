require 'rails_helper'

RSpec.describe AllocationUpdater do
  let(:mock_request) { instance_double(Computacenter::OutgoingAPI::CapUpdateRequest, timestamp: Time.zone.now, payload_id: '123456789') }
  let(:mock_update_service) { instance_double(SchoolOrderStateAndCapUpdateService) }

  before do
    allow(Computacenter::OutgoingAPI::CapUpdateRequest).to receive(:new).and_return(mock_request)
    allow(mock_request).to receive(:post!)
    allow(mock_update_service).to receive(:update!)
  end

  subject(:service) do
    described_class.new(school: school, device_type: 'std_device', value: 100)
  end

  context 'allocation exists and school can order full allocation' do
    let(:school) { create(:school, :in_lockdown) }
    let(:update_service) { instance_double('SchoolOrderStateAndCapUpdateService') }

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

    it 'calls notifies computacenter with cap updates' do
      allow(SchoolOrderStateAndCapUpdateService).to receive(:new).and_return(mock_update_service)

      service.call

      expect(SchoolOrderStateAndCapUpdateService).to have_received(:new).with(school: school, order_state: school.order_state, std_device_cap: 100, coms_device_cap: 0)
      expect(mock_update_service).to have_received(:update!)
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

    it 'calls notifies computacenter with cap updates' do
      allow(SchoolOrderStateAndCapUpdateService).to receive(:new).and_return(mock_update_service)

      service.call

      expect(SchoolOrderStateAndCapUpdateService).to have_received(:new).with(school: school, order_state: school.order_state, std_device_cap: 100, coms_device_cap: 0)
      expect(mock_update_service).to have_received(:update!)
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
