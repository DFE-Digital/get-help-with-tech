require 'rails_helper'

RSpec.describe AllocationUpdater do
  let(:mock_request) { instance_double(Computacenter::OutgoingAPI::CapUpdateRequest, timestamp: Time.zone.now, payload_id: '123456789', body: '<xml>test-request</xml>') }
  let(:mock_response) { OpenStruct.new(body: '<xml>test-response</xml>') }
  let(:mock_update_service) { instance_double(UpdateSchoolDevicesService) }

  before do
    allow(Computacenter::OutgoingAPI::CapUpdateRequest).to receive(:new).and_return(mock_request)
    allow(mock_request).to receive(:post!).and_return(mock_response)
    allow(mock_update_service).to receive(:update!)
  end

  subject(:service) do
    described_class.new(school: school, device_type: 'std_device', value: updated_value)
  end

  shared_examples 'allocation exists and school can order full allocation' do |initial:, updated:|
    let(:initial_value) { initial }
    let(:updated_value) { updated }

    let(:school) { create(:school, :in_lockdown) }
    let(:update_service) { instance_double('UpdateSchoolDevicesService') }

    before do
      create(:school_device_allocation,
             :with_std_allocation,
             allocation: initial_value,
             cap: initial_value,
             school: school)
    end

    it 'updates cap to match allocation' do
      service.call
      allocation = school.std_device_allocation.reload
      expect(allocation.allocation).to eq(updated_value)
      expect(allocation.cap).to eq(updated_value)
    end

    it 'calls notifies computacenter with cap updates' do
      allow(UpdateSchoolDevicesService).to receive(:new).and_return(mock_update_service)

      service.call

      expect(UpdateSchoolDevicesService).to have_received(:new).with(school: school, order_state: school.order_state, laptop_cap: updated_value, router_cap: 0)
      expect(mock_update_service).to have_received(:update!)
    end
  end

  it_behaves_like 'allocation exists and school can order full allocation', initial: 1, updated: 2
  it_behaves_like 'allocation exists and school can order full allocation', initial: 1, updated: 1
  it_behaves_like 'allocation exists and school can order full allocation', initial: 2, updated: 1

  shared_examples 'allocation does not exist and school can order full allocation' do |initial:, updated:|
    let(:initial_value) { initial }
    let(:updated_value) { updated }

    let(:school) { create(:school, :in_lockdown) }

    it 'updates cap to match allocation' do
      service.call
      allocation = school.std_device_allocation
      expect(allocation.allocation).to be(updated_value)
      expect(allocation.cap).to be(updated_value)
      expect(allocation).to be_persisted
    end

    it 'calls notifies computacenter with cap updates' do
      allow(UpdateSchoolDevicesService).to receive(:new).and_return(mock_update_service)

      service.call

      expect(UpdateSchoolDevicesService).to have_received(:new).with(school: school, order_state: school.order_state, laptop_cap: updated_value, router_cap: 0)
      expect(mock_update_service).to have_received(:update!)
    end
  end

  it_behaves_like 'allocation does not exist and school can order full allocation', initial: 1, updated: 2
  it_behaves_like 'allocation does not exist and school can order full allocation', initial: 1, updated: 1
  it_behaves_like 'allocation does not exist and school can order full allocation', initial: 2, updated: 1

  context 'when school can order for specific circumstances' do
    let(:initial_value) { 1 }
    let(:updated_value) { 2 }

    let(:school) { create(:school, :can_order_for_specific_circumstances) }

    before do
      create(:school_device_allocation,
             :with_std_allocation,
             allocation: initial_value,
             cap: initial_value,
             school: school)
    end

    it 'leaves cap value as is' do
      service.call
      allocation = school.std_device_allocation.reload
      expect(allocation.allocation).to be(updated_value)
      expect(allocation.cap).to be(initial_value)
    end
  end
end
