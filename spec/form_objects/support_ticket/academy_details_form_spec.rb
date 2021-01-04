require 'rails_helper'

RSpec.describe SupportTicket::AcademyDetailsForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:academy_name).with_message('Enter your academy trust name') }
  end
end
