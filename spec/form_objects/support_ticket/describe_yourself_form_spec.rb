require 'rails_helper'

RSpec.describe SupportTicket::DescribeYourselfForm, type: :model do
  subject(:form) { described_class.new }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_type).with_message('Tell us which of these best describes you') }
  end

  describe '#descibe_yourself_options' do
    it 'returns an array of label & value pairs' do
      stub_const('SupportTicket::DescribeYourselfForm::OPTIONS', { type_of_user_value: 'Type of user label' })
      expect(form.describe_yourself_options).to match_array([OpenStruct.new(value: :type_of_user_value, label: 'Type of user label')])
    end
  end

  describe '#selected_option_label' do
    it 'returns label for the selected option' do
      stub_const('SupportTicket::DescribeYourselfForm::OPTIONS', { option_1: 'Hello world' })
      expect(form.selected_option_label('option_1')).to eq('Hello world')
    end
  end
end
