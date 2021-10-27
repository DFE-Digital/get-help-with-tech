require 'rails_helper'

RSpec.describe DeviceCountComponent, type: :component do
  context 'when no devices available' do
    let(:school) { create(:school, laptops: [1, 1, 1]) }

    subject(:component) { described_class.new(school: school) }

    it 'renders availability' do
      html = render_inline(component).to_html

      expect(html).to include 'All devices ordered'
    end

    it 'renders state' do
      html = render_inline(component).to_html

      expect(html).to include 'ordered 1 of 1 device'
    end
  end

  context 'when zero allocation present' do
    let(:school) { create(:school, laptops: [1, 1, 0]) }

    subject(:component) { described_class.new(school: school) }

    it 'renders availability' do
      html = render_inline(component).to_html

      expect(html).not_to include '0 devices'
      expect(html).to include '1 device available'
    end

    it 'does not render zero allocation' do
      html = render_inline(component).to_html

      expect(html).not_to include 'ordered 0 of 0 device'
    end
  end

  context 'when devices available' do
    let(:school) do
      create(:school, laptops: [10, 5, 1])
    end

    subject(:component) { described_class.new(school: school) }

    it 'renders availability' do
      html = render_inline(component).to_html

      expect(html).to include '4 devices available'
    end

    it 'renders state' do
      html = render_inline(component).to_html

      expect(html).to include 'ordered 1 of 5 devices'
    end

    context 'when school can_order_for_specific_circumstances' do
      let(:school) do
        create(:school, :can_order_for_specific_circumstances, laptops: [10, 5, 1])
      end

      it 'renders availability with suffix' do
        content = render_inline(component).content

        expect(content).to include '4 devices available for specific circumstances'
      end
    end
  end

  context 'when all devices ordered' do
    let(:school) do
      create(:school, laptops: [10, 5, 5])
    end

    subject(:component) { described_class.new(school: school) }

    it 'renders availability' do
      html = render_inline(component).to_html

      expect(html).to include 'All devices ordered'
    end

    it 'renders state' do
      html = render_inline(component).to_html

      expect(html).to include 'ordered 5 of 5 devices'
    end
  end

  context 'with an action' do
    let(:school) { create(:school, laptops: [2, 2, 1]) }

    subject(:component) { described_class.new(school: school, action: { 'hello' => 'https://example.com' }) }

    it 'renders action button' do
      doc = render_inline(component)

      expect(doc.css("a[href='https://example.com']")[0].text).to eql('hello')
    end

    context 'when show action is true' do
      subject(:component) do
        described_class.new(school: school,
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
        described_class.new(school: school,
                            show_action: false,
                            action: { 'hello' => 'https://example.com' })
      end

      it 'does not render the action' do
        html = render_inline(component).to_html

        expect(html).not_to include 'hello'
      end
    end
  end

  context 'when school can_order_for_specific_circumstances and has_ordered' do
    let(:school) { create(:school, order_state: :can_order_for_specific_circumstances, laptops: [1, 1, 1]) }

    subject(:component) { described_class.new(school: school) }

    it 'renders availability' do
      html = render_inline(component).to_html

      expect(html).to include 'All devices ordered'
    end

    it 'renders custom state' do
      html = render_inline(component).to_html

      expect(html).not_to include 'ordered 0 of 0 devices'
      expect(html).to include 'You cannot order your full allocation yet'
    end
  end

  context 'with different allocations present' do
    let(:school) { create(:school, laptops: [10, 3, 1], routers: [10, 5, 2]) }

    subject(:component) { described_class.new(school: school) }

    it 'renders availability' do
      content = render_inline(component).content

      expect(content).to include '2 devices and 3 routers available'
    end

    it 'renders state' do
      html = render_inline(component).to_html

      expect(html).to include 'ordered 1 of 3 devices and 2 of 5 routers'
    end
  end
end
