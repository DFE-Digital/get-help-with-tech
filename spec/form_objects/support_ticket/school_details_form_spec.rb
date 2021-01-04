require 'rails_helper'

RSpec.describe SupportTicket::SchoolDetailsForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:school_name).with_message('Enter your school name') }
    it { is_expected.to validate_presence_of(:school_urn).with_message('Enter your school URN') }
  end
end
