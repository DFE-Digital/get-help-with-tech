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
    it { is_expected.not_to allow_value('invalid.email').for(:email_address) }
  end

  describe '#current_school_contact?' do
    let(:school) { build(:school) }

    subject(:contact) { build(:school_contact, school: school) }

    context 'when current school contact' do
      before do
        school.school_contact = contact
      end

      it 'returns true' do
        expect(contact.current_school_contact?).to be_truthy
      end
    end

    context 'when not current school contact' do
      it 'returns false' do
        expect(contact.current_school_contact?).to be_falsey
      end
    end
  end
end
