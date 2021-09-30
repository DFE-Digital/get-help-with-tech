require 'rails_helper'

RSpec.describe AllocationComponent, type: :component do
  describe '#available_to_order_summary' do
    context 'both zero' do
      subject { AllocationComponent.new(organisation: nil, devices_left: 0, routers_left: 0, devices_ordered: 0, routers_ordered: 0, devices_allocation: 0, routers_allocation: 0) }

      specify { expect(subject.available_to_order_summary).to eq('0 devices and 0 routers available to order') }
    end

    context 'both one' do
      subject { AllocationComponent.new(organisation: nil, devices_left: 1, routers_left: 1, devices_ordered: 0, routers_ordered: 0, devices_allocation: 0, routers_allocation: 0) }

      specify { expect(subject.available_to_order_summary).to eq('1 device and 1 router available to order') }
    end

    context 'both two' do
      subject { AllocationComponent.new(organisation: nil, devices_left: 2, routers_left: 2, devices_ordered: 0, routers_ordered: 0, devices_allocation: 0, routers_allocation: 0) }

      specify { expect(subject.available_to_order_summary).to eq('2 devices and 2 routers available to order') }
    end
  end

  describe '#ordered_summary' do
    context 'both zero' do
      subject { AllocationComponent.new(organisation: nil, devices_left: nil, routers_left: nil, devices_ordered: 0, routers_ordered: 0, devices_allocation: 0, routers_allocation: 0) }

      specify { expect(subject.ordered_summary).to eq("You've ordered 0 of 0 routers and 0 of 0 devices") }
    end

    context 'both one' do
      subject { AllocationComponent.new(organisation: nil, devices_left: nil, routers_left: nil, devices_ordered: 0, routers_ordered: 0, devices_allocation: 1, routers_allocation: 1) }

      specify { expect(subject.ordered_summary).to eq("You've ordered 0 of 1 router and 0 of 1 device") }
    end
  end
end
