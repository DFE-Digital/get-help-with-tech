require 'rails_helper'

RSpec.describe ResponsibleBody::PooledDeviceCountComponent, type: :component do
  context 'when no devices available' do
    let(:responsible_body) { create(:trust, :manages_centrally, virtual_cap_pools: [pooled_allocation]) }
    let(:pooled_allocation) { VirtualCapPool.new(devices_ordered: 0, cap: 0, device_type: 'std_device') }

    subject(:component) { described_class.new(responsible_body: responsible_body) }

    it 'renders availability' do
      html = render_inline(component).to_html

      expect(html).to include 'No devices left to order'
    end

    it 'renders state' do
      html = render_inline(component).to_html

      expect(html).to include 'ordered 0 devices'
    end
  end

  context 'with an action' do
    let(:responsible_body) { create(:trust, :manages_centrally, virtual_cap_pools: [pooled_allocation]) }
    let(:pooled_allocation) { VirtualCapPool.new(devices_ordered: 0, cap: 0, device_type: 'std_device') }

    subject(:component) { described_class.new(responsible_body: responsible_body, action: { 'hello' => 'https://example.com' }) }

    it 'renders action button' do
      doc = render_inline(component)

      expect(doc.css("a[href='https://example.com']")[0].text).to eql('hello')
    end

    context 'when show action is true' do
      subject(:component) do
        described_class.new(responsible_body: responsible_body,
                            show_action: true,
                            action: { 'hello' => 'https://example.com' })
      end

      it 'renders the action' do
        doc = render_inline(component)

        expect(doc.css("a[href='https://example.com']")[0].text).to eql('hello')
      end
    end

    context 'when show action is false' do
      subject(:component) do
        described_class.new(responsible_body: responsible_body,
                            show_action: false,
                            action: { 'hello' => 'https://example.com' })
      end

      it 'does not render the action' do
        html = render_inline(component).to_html

        expect(html).not_to include 'hello'
      end
    end
  end

  context 'when devices available' do
    let(:responsible_body) { create(:trust, :manages_centrally, virtual_cap_pools: [pooled_allocation]) }
    let(:pooled_allocation) { VirtualCapPool.new(devices_ordered: 1, cap: 5, device_type: 'std_device') }

    subject(:component) { described_class.new(responsible_body: responsible_body) }

    it 'renders availability' do
      html = render_inline(component).to_html

      expect(html).to include '4 devices available to order'
    end

    it 'renders state' do
      html = render_inline(component).to_html

      expect(html).to include 'ordered 1 device'
    end
  end

  context 'when all devices ordered' do
    let(:responsible_body) { create(:trust, :manages_centrally, virtual_cap_pools: [pooled_allocation]) }
    let(:pooled_allocation) { VirtualCapPool.new(devices_ordered: 5, cap: 5, device_type: 'std_device') }

    subject(:component) { described_class.new(responsible_body: responsible_body) }

    it 'renders availability' do
      html = render_inline(component).to_html

      expect(html).to include 'No devices left to order'
    end

    it 'renders state' do
      html = render_inline(component).to_html

      expect(html).to include 'ordered 5 devices'
    end
  end

  context 'with different allocations present' do
    let(:pooled_allocation1) { VirtualCapPool.new(device_type: 'std_device', devices_ordered: 1, cap: 3) }
    let(:pooled_allocation2) { VirtualCapPool.new(device_type: 'coms_device', devices_ordered: 2, cap: 5) }
    let(:responsible_body) { create(:trust, :manages_centrally, virtual_cap_pools: [pooled_allocation1, pooled_allocation2]) }

    subject(:component) { described_class.new(responsible_body: responsible_body) }

    it 'renders availability' do
      content = render_inline(component).content

      expect(content).to include '2 devices and 3 routers available to order'
    end

    it 'renders state' do
      html = render_inline(component).to_html

      expect(html).to include 'ordered 1 device and 2 routers'
    end
  end
end
