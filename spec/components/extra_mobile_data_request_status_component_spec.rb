require 'rails_helper'

RSpec.describe ExtraMobileDataRequestStatusComponent, type: :component do
  subject(:component) { described_class.new(extra_mobile_data_request: extra_mobile_data_request) }

  context 'for a queried request' do
    let(:extra_mobile_data_request) do
      create(:extra_mobile_data_request, status: :queried, problem: :incorrect_phone_number)
    end

    it 'is coloured red' do
      html = render_inline(component).to_html

      expect(html).to include 'govuk-tag--red'
    end

    it 'shows the relevant label' do
      html = render_inline(component).to_html

      expect(html).to include 'Invalid number'
    end
  end

  context 'for a complete request' do
    let(:extra_mobile_data_request) do
      create(:extra_mobile_data_request, status: :complete, problem: :incorrect_phone_number)
    end

    it 'is coloured green' do
      html = render_inline(component).to_html

      expect(html).to include 'govuk-tag--green'
    end

    it 'shows the relevant label' do
      html = render_inline(component).to_html

      expect(html).to include 'Complete'
    end
  end
end
