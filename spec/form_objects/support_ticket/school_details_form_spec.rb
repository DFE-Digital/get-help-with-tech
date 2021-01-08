require 'rails_helper'

RSpec.describe SupportTicket::SchoolDetailsForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:school_name).with_message('Enter your school name') }

    describe 'URN' do
      it { is_expected.to validate_presence_of(:school_urn).with_message('Enter your school URN') }
      it { is_expected.to allow_value('123456').for(:school_urn) }
      it { is_expected.not_to allow_value('12345678').for(:school_urn) }
      it { is_expected.not_to allow_value('1234').for(:school_urn) }
      it { is_expected.not_to allow_value('1234-Q').for(:school_urn) }
    end
  end
end
