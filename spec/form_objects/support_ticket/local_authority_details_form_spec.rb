require 'rails_helper'

RSpec.describe SupportTicket::LocalAuthorityDetailsForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:local_authority_name).with_message('Enter your local authority name') }
  end
end
