require 'rails_helper'

RSpec.describe ResponsibleBody::PooledDeviceCountComponent, type: :component do
  before { stub_computacenter_outgoing_api_calls }

  context 'when no devices available' do
    let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag) }

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
    let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag) }

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
    let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag, laptops: [5, 5, 1]) }

    subject(:component) { described_class.new(responsible_body: responsible_body) }

    it 'renders availability' do
      content = render_inline(component).content

      expect(content).to include '4 devices and 0 routers available to order'
    end

    it 'renders state' do
      html = render_inline(component).to_html

      expect(html).to include 'ordered 1 device and 0 routers'
    end
  end

  context 'when all devices ordered' do
    let(:responsible_body) { create(:trust, :manages_centrally, :vcap_feature_flag, laptops: [5, 5, 5]) }

    subject(:component) { described_class.new(responsible_body: responsible_body) }

    it 'renders availability' do
      html = render_inline(component).to_html

      expect(html).to include 'No devices left to order'
    end

    it 'renders state' do
      html = render_inline(component).to_html

      expect(html).to include 'ordered 5 devices and 0 routers'
    end
  end

  context 'with different allocations present' do
    let(:responsible_body) do
      create(:trust, :manages_centrally, :vcap_feature_flag, laptops: [3, 3, 1], routers: [5, 5, 2])
    end

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
