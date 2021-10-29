require 'rails_helper'

RSpec.describe TrancheAllocationComponent, type: :component do
  let(:school) { create(:school) }
  let(:rb) { build(:responsible_body) }

  describe '#total_allocation_sentence' do
    let(:rb_with_name) { build(:responsible_body, name: 'Trent Trust') }

    context 'zero devices' do
      subject { described_class.new(organisation: rb_with_name, devices_ordered: 0, routers_ordered: 0, devices_allocation: 0) }

      it { is_expected.to have_attributes(total_allocation_sentence: 'Trent Trust has a total allocation of 0 devices for academic year 2021/22.') }
    end

    context 'one device' do
      subject { described_class.new(organisation: rb_with_name, devices_ordered: 0, routers_ordered: 0, devices_allocation: 1) }

      it { is_expected.to have_attributes(total_allocation_sentence: 'Trent Trust has a total allocation of 1 device for academic year 2021/22.') }
    end

    context 'more than one' do
      subject { described_class.new(organisation: rb_with_name, devices_ordered: 0, routers_ordered: 0, devices_allocation: 2) }

      it { is_expected.to have_attributes(total_allocation_sentence: 'Trent Trust has a total allocation of 2 devices for academic year 2021/22.') }
    end
  end

  describe '#ordered_sentence' do
    context 'both zero' do
      subject(:component) { described_class.new(organisation: nil, devices_ordered: 0, routers_ordered: 0, devices_allocation: 0) }

      it { is_expected.to have_attributes(ordered_sentence: 'You&rsquo;ve received 0 devices and 0 routers in academic year 2021/22.') }
      specify { expect(component.ordered_sentence).to be_html_safe }
    end

    context 'both one' do
      subject { described_class.new(organisation: nil, devices_ordered: 1, routers_ordered: 1, devices_allocation: 1) }

      it { is_expected.to have_attributes(ordered_sentence: 'You&rsquo;ve received 1 device and 1 router in academic year 2021/22.') }
    end

    context 'both two' do
      subject { described_class.new(organisation: nil, devices_ordered: 2, routers_ordered: 2, devices_allocation: 2) }

      it { is_expected.to have_attributes(ordered_sentence: 'You&rsquo;ve received 2 devices and 2 routers in academic year 2021/22.') }
    end
  end

  describe 'component' do
    describe '.new' do
      let(:organisation) { school }
      let(:sentry_scope) { double }

      before do
        allow(sentry_scope).to receive(:set_context)
        allow(Sentry).to receive(:capture_message)
        allow(Sentry).to receive(:with_scope).and_yield(sentry_scope)

        render_inline(component)
      end

      context 'invalid' do
        context 'negative number' do
          let(:component) { described_class.new(organisation: organisation, devices_ordered: -1, routers_ordered: 0, devices_allocation: 0) }

          specify { expect(sentry_scope).to have_received(:set_context).with('TrancheAllocationComponent.new', organisation_id: organisation.id) }
          specify { expect(Sentry).to have_received(:capture_message).with('Contains negative number') }
          specify { expect(rendered_component).to be_blank }
        end
      end

      context 'valid' do
        let(:component) { described_class.new(organisation: organisation, devices_ordered: 0, routers_ordered: 0, devices_allocation: 0) }

        specify { expect(sentry_scope).not_to have_received(:set_context) }
        specify { expect(Sentry).not_to have_received(:capture_message) }

        specify { expect(rendered_component).to be_present }
        specify { expect(rendered_component).to have_css('#total_allocation_sentence') }
        specify { expect(rendered_component).to have_css('#ordered_sentence') }
        specify { expect(rendered_component).to have_css('#current_tranche') }
      end
    end
  end
end
