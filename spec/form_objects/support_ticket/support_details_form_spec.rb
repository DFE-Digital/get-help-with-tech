require 'rails_helper'

RSpec.describe SupportTicket::SupportDetailsForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:message).with_message('Tell us how can we help you') }
  end
end
