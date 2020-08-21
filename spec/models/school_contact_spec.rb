require 'rails_helper'

RSpec.describe SchoolContact, type: :model do
  describe 'associations' do
    let(:school) { create(:school) }

    subject { build(:school_contact, school: school) }

    it { is_expected.to belong_to(:school) }
  end

  describe 'validations' do
    subject { build(:school_contact) }

    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_uniqueness_of(:email_address).scoped_to(:school_id) }
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:role) }
  end
end
