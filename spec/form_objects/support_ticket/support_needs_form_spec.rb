require 'rails_helper'

RSpec.describe SupportTicket::SupportNeedsForm, type: :model do
  subject(:form) { described_class.new }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:support_topics).with_message('Tell us what you need help with') }
  end

  describe '#support_needs_options' do
    it 'returns an array of label & value pairs' do
      stub_const('SupportTicket::SupportNeedsForm::OPTIONS', { support_1: 'Support option 1' })
      expect(form.support_needs_options).to match_array([OpenStruct.new(value: :support_1, label: 'Support option 1')])
    end
  end

  describe '#selected_option_label' do
    it 'returns label for the selected option' do
      stub_const('SupportTicket::SupportNeedsForm::OPTIONS', { option_1: 'Hello world' })
      expect(form.selected_option_label(:option_1)).to eq('Hello world')
    end
  end
end
