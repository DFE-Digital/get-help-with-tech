require 'rails_helper'

RSpec.describe SupportTicket::ContactDetailsForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:full_name).with_message('Enter your full name') }

    describe 'email_address' do
      it { is_expected.to validate_presence_of(:email_address).with_message('Enter your email address') }
      it { is_expected.not_to allow_value('@').for(:email_address) }
      it { is_expected.not_to allow_value('invalid.email').for(:email_address) }
      it { is_expected.not_to allow_value('myname.com').for(:email_address) }
      it { is_expected.to allow_value('my_name@doman.com').for(:email_address) }
    end
  end
end
