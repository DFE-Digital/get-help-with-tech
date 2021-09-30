require 'rails_helper'

RSpec.describe TrancheAllocationComponent, type: :component do
  let(:school) { build(:school) }
  let(:rb) { build(:responsible_body) }

  describe 'intro_sentence' do
    context 'RB' do
      let(:rb_with_name) { build(:responsible_body, name: 'Trent Trust') }

      subject { described_class.new(organisation: rb_with_name, devices_remaining: 0, routers_remaining: 0, devices_ordered: 0, routers_ordered: 0, devices_allocation: 0, routers_allocation: 0) }

      it { is_expected.to have_attributes(intro_sentence: 'Trent Trust has:') }
    end

    context 'school' do
      let(:component) { described_class.new(organisation: school, devices_remaining: 0, routers_remaining: 0, devices_ordered: 0, routers_ordered: 0, devices_allocation: 0, routers_allocation: 0) }

      specify { expect { component.intro_sentence }.to raise_error('Invalid for school') }
    end
  end

  describe '#available_to_order_summary' do
    context 'both zero' do
      subject { described_class.new(organisation: nil, devices_remaining: 0, routers_remaining: 0, devices_ordered: 0, routers_ordered: 0, devices_allocation: 0, routers_allocation: 0) }

      it { is_expected.to have_attributes(available_to_order_summary: '0 devices and 0 routers available to order') }
    end

    context 'both one' do
      subject { described_class.new(organisation: nil, devices_remaining: 1, routers_remaining: 1, devices_ordered: 0, routers_ordered: 0, devices_allocation: 1, routers_allocation: 1) }

      it { is_expected.to have_attributes(available_to_order_summary: '1 device and 1 router available to order') }
    end

    context 'both two' do
      subject { described_class.new(organisation: nil, devices_remaining: 2, routers_remaining: 2, devices_ordered: 0, routers_ordered: 0, devices_allocation: 2, routers_allocation: 2) }

      it { is_expected.to have_attributes(available_to_order_summary: '2 devices and 2 routers available to order') }
    end
  end

  describe '#ordered_summary' do
    context 'both zero' do
      subject(:component) { described_class.new(organisation: nil, devices_remaining: 0, routers_remaining: 0, devices_ordered: 0, routers_ordered: 0, devices_allocation: 0, routers_allocation: 0) }

      it { is_expected.to have_attributes(ordered_summary: 'You&rsquo;ve ordered 0 of 0 devices and 0 of 0 routers') }
      specify { expect(component.ordered_summary).to be_html_safe }
    end

    context 'both one' do
      subject { described_class.new(organisation: nil, devices_remaining: 1, routers_remaining: 1, devices_ordered: 0, routers_ordered: 0, devices_allocation: 1, routers_allocation: 1) }

      it { is_expected.to have_attributes(ordered_summary: 'You&rsquo;ve ordered 0 of 1 device and 0 of 1 router') }
    end

    context 'both two' do
      subject { described_class.new(organisation: nil, devices_remaining: 2, routers_remaining: 2, devices_ordered: 0, routers_ordered: 0, devices_allocation: 2, routers_allocation: 2) }

      it { is_expected.to have_attributes(ordered_summary: 'You&rsquo;ve ordered 0 of 2 devices and 0 of 2 routers') }
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
          let(:component) { described_class.new(organisation: nil, devices_remaining: -1, routers_remaining: 0, devices_ordered: 1, routers_ordered: 0, devices_allocation: 0, routers_allocation: 0) }

          specify { expect(sentry_scope).to have_received(:set_context).with('TrancheAllocationComponent.new', organisation_id: organisation.id) }
          specify { expect(Sentry).to have_received(:capture_message).with('Contains negative number') }
          specify { expect(rendered_component).to be_blank }
        end

        context 'summation wrong' do
          let(:component) { described_class.new(organisation: organisation, devices_remaining: 2, routers_remaining: 0, devices_ordered: 2, routers_ordered: 0, devices_allocation: 5, routers_allocation: 0) }

          specify { expect(sentry_scope).to have_received(:set_context).with('TrancheAllocationComponent.new', organisation_id: organisation.id) }
          specify { expect(Sentry).to have_received(:capture_message).with('Expected allocation == ordered + remaining, but 5 != 2 + 2') }
          specify { expect(rendered_component).to be_blank }
        end
      end

      context 'valid' do
        let(:component) { described_class.new(organisation: organisation, devices_remaining: 0, routers_remaining: 0, devices_ordered: 0, routers_ordered: 0, devices_allocation: 0, routers_allocation: 0) }

        specify { expect(sentry_scope).not_to have_received(:set_context) }
        specify { expect(Sentry).not_to have_received(:capture_message) }
        specify { expect(rendered_component).to be_present }
      end
    end

    context 'RB' do
      subject { render_inline(described_class.new(organisation: rb, devices_remaining: 0, routers_remaining: 0, devices_ordered: 0, routers_ordered: 0, devices_allocation: 0, routers_allocation: 0)) }

      it { is_expected.to have_css('#intro') }
      it { is_expected.to have_css('#available_summary') }
      it { is_expected.to have_css('#ordered_summary') }
      it { is_expected.to have_css('#current_tranche') }
    end

    context 'school' do
      subject { render_inline(described_class.new(organisation: school, devices_remaining: 0, routers_remaining: 0, devices_ordered: 0, routers_ordered: 0, devices_allocation: 0, routers_allocation: 0)) }

      it { is_expected.to have_no_css('#intro') }
      it { is_expected.to have_css('#available_summary') }
      it { is_expected.to have_css('#ordered_summary') }
      it { is_expected.to have_css('#current_tranche') }
    end
  end
end
