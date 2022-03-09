require 'rails_helper'

RSpec.describe AllocationComponent, type: :component do
  let(:school) { create(:school) }
  let(:rb) { build(:responsible_body) }

  describe '#ordering_closed_sentence' do
    let(:rb_with_name) { build(:responsible_body, name: 'Trent Trust') }

    subject { described_class.new(organisation: rb_with_name, devices_available: 0, devices_ordered: 1, routers_ordered: 0, devices_allocation: 2) }

    it { is_expected.to have_attributes(ordering_closed_sentence: 'Ordering is now closed') }
  end

  describe '#devices_ordered_sentence' do
    let(:rb_with_name) { build(:responsible_body, name: 'Trent Trust') }

    context 'zero devices' do
      subject { described_class.new(organisation: rb_with_name, devices_available: 0, devices_ordered: 0, routers_ordered: 0, devices_allocation: 0) }

      it { is_expected.to have_attributes(devices_ordered_sentence: 'Trent Trust ordered 0 devices and 0 routers in academic year 2021/22.') }
    end

    context 'one device' do
      subject { described_class.new(organisation: rb_with_name, devices_available: 0, devices_ordered: 0, routers_ordered: 1, devices_allocation: 1) }

      it { is_expected.to have_attributes(devices_ordered_sentence: 'Trent Trust ordered 0 devices and 1 router in academic year 2021/22.') }
    end

    context 'more than one' do
      subject { described_class.new(organisation: rb_with_name, devices_available: 0, devices_ordered: 1, routers_ordered: 0, devices_allocation: 2) }

      it { is_expected.to have_attributes(devices_ordered_sentence: 'Trent Trust ordered 1 device and 0 routers in academic year 2021/22.') }
    end
  end

  describe 'component' do
    describe '.new' do
      let(:organisation) { school }
      let(:sentry_scope) { double }

      let(:component) { described_class.new(organisation: organisation, devices_available: 0, devices_ordered: 0, routers_ordered: 0, devices_allocation: 0) }

      before do
        allow(sentry_scope).to receive(:set_context)
        allow(Sentry).to receive(:capture_message)
        allow(Sentry).to receive(:with_scope).and_yield(sentry_scope)

        render_inline(component)
      end

      context 'valid' do
        specify { expect(sentry_scope).not_to have_received(:set_context) }
        specify { expect(Sentry).not_to have_received(:capture_message) }

        specify { expect(rendered_component).to be_present }
        specify { expect(rendered_component).to have_css('#devices_ordered_sentence') }
      end
    end
  end
end
