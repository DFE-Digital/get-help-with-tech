require 'rails_helper'

RSpec.describe SupportTicket::ContactDetailsForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:full_name).with_message('Enter your full name') }
    it { is_expected.to validate_presence_of(:email_address).with_message('Enter your email address') }
  end
end
