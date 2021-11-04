require 'rails_helper'

RSpec.describe OrderDevicesComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:school) { build(:school) }
  let(:rb) { build(:responsible_body) }

  describe 'rendered component' do
    context 'school' do
      let(:component) { described_class.new(organisation: school) }

      context 'should be able to order' do
        before do
          allow(school).to receive(:orders_managed_centrally?).and_return(true)
          allow(school).to receive(:devices_ordered).with(:laptop).and_return(0)
          allow(school).to receive(:cap).with(:laptop).and_return(1)
          render_inline(component)
        end

        specify { expect(rendered_component).to have_link('Order devices', href: order_devices_responsible_body_devices_school_path(urn: school.urn)) }
      end

      context 'should not be able to order' do
        before { render_inline(component) }

        specify { expect(rendered_component).not_to be_present }
      end
    end

    context 'RB' do
      let(:component) { described_class.new(organisation: rb) }

      context 'should be able to order' do
        before do
          allow(rb).to receive(:has_any_schools_that_can_order_now?).and_return(true)
          allow(rb).to receive(:devices_available_to_order?).and_return(true)
          render_inline(component)
        end

        specify { expect(rendered_component).to have_link('Order devices', href: responsible_body_devices_order_devices_path) }
      end

      context 'should not be able to order' do
        before { render_inline(component) }

        specify { expect(rendered_component).not_to be_present }
      end
    end
  end
end
