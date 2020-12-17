require 'rails_helper'

RSpec.describe SupportTicket::CollegeDetailsForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:college_name).with_message('Enter your college name') }
    it { is_expected.to validate_presence_of(:college_ukprn).with_message('Enter your college UKPRN') }
  end
end
