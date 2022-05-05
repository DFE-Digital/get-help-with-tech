require 'rails_helper'

RSpec.describe SupportTicket::DescribeYourselfForm, type: :model do
  subject(:form) { described_class.new }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_type).with_message('Tell us which of these best describes you') }

    it {
      expect(form).to validate_inclusion_of(:user_type)
                        .in_array(%w[college
                                     local_authority
                                     multi_academy_trust
                                     other_type_of_user
                                     parent_or_guardian_or_carer_or_pupil_or_care_leaver
                                     school_or_single_academy_trust])
                        .with_message('Wrong user type')
    }
  end

  describe '#descibe_yourself_options' do
    it 'returns an array of SupportTicket::Options' do
      allow(Rails.configuration.support_tickets).to receive(:[]).with(:describe_yourself_options).and_return([{ value: :type_of_user_value, label: 'Type of user label' }])
      expect(form.describe_yourself_options).to be_an(Array)
      expect(form.describe_yourself_options.first).to be_a(SupportTicket::Option)
      expect(form.describe_yourself_options.first.value).to eq(:type_of_user_value)
      expect(form.describe_yourself_options.first.label).to eq('Type of user label')
    end
  end

  describe '#selected_option_label' do
    it 'returns label for the selected option' do
      allow(Rails.configuration.support_tickets).to receive(:[]).with(:describe_yourself_options).and_return([{ value: :option_1, label: 'Hello world' }])
      expect(form.selected_option_label(:option_1)).to eq('Hello world')
    end
  end
end
