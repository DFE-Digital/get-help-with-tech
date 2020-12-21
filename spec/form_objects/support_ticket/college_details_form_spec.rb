require 'rails_helper'

RSpec.describe SupportTicket::CollegeDetailsForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:college_name).with_message('Enter your college name') }

    describe 'UKPRN' do
      it { is_expected.to validate_presence_of(:college_ukprn).with_message('Enter your college UKPRN') }
      it { is_expected.to allow_value('12345678').for(:college_ukprn) }
      it { is_expected.not_to allow_value('1234567890').for(:college_ukprn) }
      it { is_expected.not_to allow_value('1234567').for(:college_ukprn) }
      it { is_expected.not_to allow_value('123456-Q').for(:college_ukprn) }
    end
  end
end
