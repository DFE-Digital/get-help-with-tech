require 'rails_helper'

RSpec.describe DeviceCountComponent, type: :component do
  context 'when no devices available' do
    subject(:component) { described_class.new(max_count: 0, ordered_count: 0) }

    it 'renders availability' do
      html = render_inline(component).to_html

      expect(html).to include '0 devices available'
    end

    it 'renders state' do
      html = render_inline(component).to_html

      expect(html).to include 'ordered 0 of 0 devices'
    end
  end

  context 'when devices available' do
    subject(:component) { described_class.new(max_count: 5, ordered_count: 1) }

    it 'renders availability' do
      html = render_inline(component).to_html

      expect(html).to include '4 devices available'
    end

    it 'renders state' do
      html = render_inline(component).to_html

      expect(html).to include 'ordered 1 of 5 devices'
    end
  end

  context 'when all devices ordered' do
    subject(:component) { described_class.new(max_count: 5, ordered_count: 5) }

    it 'renders availability' do
      html = render_inline(component).to_html

      expect(html).to include '0 devices available'
    end

    it 'renders state' do
      html = render_inline(component).to_html

      expect(html).to include 'ordered 5 of 5 devices'
    end
  end

  context 'with an action' do
    subject(:component) { described_class.new(max_count: 3, ordered_count: 1, action: { 'hello' => 'https://example.com' }) }

    it 'renders action button' do
      doc = render_inline(component)

      expect(doc.css("a[href='https://example.com']")[0].text).to eql('hello')
    end

    context 'when show action is true' do
      subject(:component) do
        described_class.new(max_count: 3,
                            ordered_count: 1,
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
        described_class.new(max_count: 3,
                            ordered_count: 1,
                            show_action: false,
                            action: { 'hello' => 'https://example.com' })
      end

      it 'does not render the action' do
        html = render_inline(component).to_html

        expect(html).not_to include 'hello'
      end
    end
  end
end
