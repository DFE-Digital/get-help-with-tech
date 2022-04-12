require 'rails_helper'

RSpec.describe SupportTicket::SupportNeedsForm, type: :model do
  subject(:form) { described_class.new }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:support_topics).with_message('Tell us what you need help with') }
  end

  describe '#support_needs_options' do
    it 'returns an array of SupportTicket::Options' do
      allow(Rails.configuration.support_tickets).to receive(:[]).with(:support_needs_options).and_return([{ value: :type_of_user_value, label: 'Type of user label' }])
      expect(form.support_needs_options).to be_an(Array)
      expect(form.support_needs_options.first).to be_a(SupportTicket::Option)
      expect(form.support_needs_options.first.value).to eq(:type_of_user_value)
      expect(form.support_needs_options.first.label).to eq('Type of user label')
    end
  end

  describe '#selected_option_label' do
    it 'returns label for the selected option' do
      allow(Rails.configuration.support_tickets).to receive(:[]).with(:support_needs_options).and_return([{ value: :option_1, label: 'Hello world' }])
      expect(form.selected_option_label(:option_1)).to eq('Hello world')
    end
  end
end
