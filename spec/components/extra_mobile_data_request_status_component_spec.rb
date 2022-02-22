require 'rails_helper'

RSpec.describe ExtraMobileDataRequestStatusComponent, type: :component do
  subject(:component) { described_class.new(status:) }

  let(:html) { render_inline(component).to_html }

  context 'for a request with a problem' do
    let(:status) { :problem_incorrect_phone_number }

    it 'is coloured red' do
      expect(html).to include 'govuk-tag--red'
    end

    it 'shows the relevant label' do
      expect(html).to include 'Invalid number'
    end
  end

  context 'for a complete request' do
    let(:status) { :complete }

    it 'is coloured green' do
      expect(html).to include 'govuk-tag--green'
    end

    it 'shows the relevant label' do
      expect(html).to include 'Complete'
    end
  end

  context 'for a new request shown to a school or RB user' do
    let(:status) { :new }

    it 'shows a “Requested” label to school or RB users' do
      expect(html).to include 'Requested'
    end
  end

  context 'for a new request shown to an MNO user' do
    subject(:component) do
      described_class.new(status: :new, viewer: :mno_user)
    end

    it 'shows a “New” label to school or RB users' do
      expect(html).to include 'New'
    end
  end
end
