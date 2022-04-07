require 'rails_helper'

RSpec.describe SupportTicket::DescribeYourselfForm, type: :model do
  subject(:form) { described_class.new }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_type).with_message('Tell us which of these best describes you') }
  end

  describe '#descibe_yourself_options' do
    it 'returns an array of SupportTicket::Options' do
      stub_const('SupportTicket::DescribeYourselfForm::OPTIONS', [{ value: :type_of_user_value, label: 'Type of user label' }])
      expect(form.describe_yourself_options).to be_an(Array)
      expect(form.describe_yourself_options.first).to be_a(SupportTicket::Option)
      expect(form.describe_yourself_options.first.value).to eq(:type_of_user_value)
      expect(form.describe_yourself_options.first.label).to eq('Type of user label')
    end
  end

  describe '#selected_option_label' do
    it 'returns label for the selected option' do
      stub_const('SupportTicket::DescribeYourselfForm::OPTIONS', [{ value: :option_1, label: 'Hello world' }])
      expect(form.selected_option_label(:option_1)).to eq('Hello world')
    end
  end
end
