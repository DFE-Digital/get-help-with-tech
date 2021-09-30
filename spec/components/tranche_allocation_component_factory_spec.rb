require 'rails_helper'

RSpec.describe TrancheAllocationComponentFactory do
  describe '.initialize' do
    let(:organisation) { spy }

    before { described_class.create_component(organisation) }

    specify { expect(organisation).to have_received(:laptops_available_to_order) }
    specify { expect(organisation).to have_received(:routers_available_to_order) }
    specify { expect(organisation).to have_received(:laptops_ordered) }
    specify { expect(organisation).to have_received(:routers_ordered) }
    specify { expect(organisation).to have_received(:laptop_allocation) }
    specify { expect(organisation).to have_received(:router_allocation) }

    specify { expect(described_class.create_component(organisation)).to be_an_instance_of(TrancheAllocationComponent) }
  end
end
