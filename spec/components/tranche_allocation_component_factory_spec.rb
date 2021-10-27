require 'rails_helper'

RSpec.describe TrancheAllocationComponentFactory do
  describe '.initialize' do
    let(:organisation) { spy }

    before { described_class.create_component(organisation) }

    specify { expect(organisation).to have_received(:devices_available_to_order).with(:laptop) }
    specify { expect(organisation).to have_received(:devices_available_to_order).with(:router) }
    specify { expect(organisation).to have_received(:devices_ordered).with(:laptop) }
    specify { expect(organisation).to have_received(:devices_ordered).with(:router) }
    specify { expect(organisation).to have_received(:allocation).with(:laptop) }
    specify { expect(organisation).to have_received(:allocation).with(:router) }

    specify { expect(described_class.create_component(organisation)).to be_an_instance_of(TrancheAllocationComponent) }
  end
end
